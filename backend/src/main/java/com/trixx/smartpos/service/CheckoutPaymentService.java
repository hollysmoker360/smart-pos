package com.trixx.smartpos.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.trixx.smartpos.model.*;
import com.trixx.smartpos.repository.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
public class CheckoutPaymentService {

    private final ShoppingSessionRepository sessionRepository;
    private final OrderRepository orderRepository;
    private final PaymentAttemptRepository paymentAttemptRepository;
    private final CatalogService catalogService;
    private final OutboxEventRepository outboxEventRepository;
    private final ObjectMapper objectMapper;

    @Value("${trixx.daraja.mode:MOCK}")
    private String darajaMode;

    public CheckoutPaymentService(
            ShoppingSessionRepository sessionRepository,
            OrderRepository orderRepository,
            PaymentAttemptRepository paymentAttemptRepository,
            CatalogService catalogService,
            OutboxEventRepository outboxEventRepository,
            ObjectMapper objectMapper) {
        this.sessionRepository = sessionRepository;
        this.orderRepository = orderRepository;
        this.paymentAttemptRepository = paymentAttemptRepository;
        this.catalogService = catalogService;
        this.outboxEventRepository = outboxEventRepository;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public Order checkout(UUID sessionId) {
        ShoppingSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Shopping session not found: " + sessionId));

        if (session.getItems().isEmpty()) {
            throw new IllegalStateException("Cannot checkout an empty basket");
        }

        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalTax = BigDecimal.ZERO;

        List<OrderItem> orderItems = new ArrayList<>();

        Order order = Order.builder()
                .tenantId(session.getTenantId())
                .branchId(session.getBranchId())
                .sessionId(session.getId())
                .orderNumber("ORD-" + System.currentTimeMillis())
                .customerId(session.getCustomerId())
                .status("PENDING")
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        for (ShoppingSessionItem item : session.getItems()) {
            Product product = catalogService.resolveProductByBarcode(item.getBarcode())
                    .orElseThrow(() -> new IllegalArgumentException("Product not found for barcode: " + item.getBarcode()));

            BigDecimal currentPrice = catalogService.getEffectivePrice(session.getBranchId(), product.getId());
            BigDecimal itemTotal = currentPrice.multiply(BigDecimal.valueOf(item.getQuantity()));
            BigDecimal itemTax = itemTotal.multiply(product.getTaxRate()).divide(new BigDecimal("100"));

            totalAmount = totalAmount.add(itemTotal);
            totalTax = totalTax.add(itemTax);

            OrderItem orderItem = OrderItem.builder()
                    .order(order)
                    .productId(product.getId())
                    .productName(product.getName())
                    .barcode(item.getBarcode())
                    .unitPrice(currentPrice)
                    .quantity(item.getQuantity())
                    .taxAmount(itemTax)
                    .totalPrice(itemTotal)
                    .build();

            orderItems.add(orderItem);
        }

        order.setTotalAmount(totalAmount);
        order.setTaxAmount(totalTax);
        order.setItems(orderItems);

        session.setStatus("CHECKOUT_PENDING");
        sessionRepository.save(session);

        Order savedOrder = orderRepository.save(order);
        publishOutboxEvent(savedOrder.getTenantId(), savedOrder.getBranchId(), "OrderCreated", savedOrder.getId().toString(),
                Map.of("orderId", savedOrder.getId().toString(), "amount", savedOrder.getTotalAmount()));

        return savedOrder;
    }

    @Transactional
    public PaymentAttempt initiateMpesaPayment(UUID orderId, String phoneNumber) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        String merchantReqId = "MREQ-" + UUID.randomUUID().toString().substring(0, 8);
        String checkoutReqId = "CHK-" + UUID.randomUUID().toString().substring(0, 8);

        PaymentAttempt attempt = PaymentAttempt.builder()
                .tenantId(order.getTenantId())
                .branchId(order.getBranchId())
                .orderId(order.getId())
                .phoneNumber(phoneNumber)
                .amount(order.getTotalAmount())
                .provider("MPESA")
                .merchantRequestId(merchantReqId)
                .checkoutRequestId(checkoutReqId)
                .status("PENDING")
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        attempt = paymentAttemptRepository.save(attempt);

        publishOutboxEvent(order.getTenantId(), order.getBranchId(), "PaymentInitiated", attempt.getId().toString(),
                Map.of("paymentAttemptId", attempt.getId().toString(), "checkoutRequestId", checkoutReqId));

        return attempt;
    }

    @Transactional
    public void processDarajaCallback(Map<String, Object> callbackData) {
        try {
            Map<String, Object> body = (Map<String, Object>) callbackData.get("Body");
            Map<String, Object> stkCallback = (Map<String, Object>) body.get("stkCallback");

            String merchantRequestId = (String) stkCallback.get("MerchantRequestID");
            String checkoutRequestId = (String) stkCallback.get("CheckoutRequestID");
            Integer resultCode = stkCallback.get("ResultCode") != null ? ((Number) stkCallback.get("ResultCode")).intValue() : -1;

            PaymentAttempt attempt = paymentAttemptRepository
                    .findByMerchantRequestIdAndCheckoutRequestId(merchantRequestId, checkoutRequestId)
                    .orElseThrow(() -> new IllegalArgumentException("Payment attempt not found for callback"));

            if ("SUCCEEDED".equals(attempt.getStatus()) || "FAILED".equals(attempt.getStatus())) {
                // Duplicate callback protection
                return;
            }

            if (resultCode == 0) {
                attempt.setStatus("SUCCEEDED");
                attempt.setUpdatedAt(Instant.now());
                paymentAttemptRepository.save(attempt);

                Order order = orderRepository.findById(attempt.getOrderId()).orElseThrow();
                order.setStatus("PAID");
                order.setUpdatedAt(Instant.now());
                orderRepository.save(order);

                // Commit inventory movements exactly once
                for (OrderItem item : order.getItems()) {
                    catalogService.recordInventoryMovement(
                            order.getTenantId(),
                            order.getBranchId(),
                            item.getProductId(),
                            "SALE",
                            BigDecimal.valueOf(item.getQuantity()),
                            order.getOrderNumber(),
                            "M-Pesa Self Checkout",
                            null
                    );
                }

                publishOutboxEvent(order.getTenantId(), order.getBranchId(), "PaymentSucceeded", attempt.getId().toString(),
                        Map.of("orderId", order.getId().toString(), "paymentAttemptId", attempt.getId().toString()));
            } else {
                attempt.setStatus("FAILED");
                attempt.setUpdatedAt(Instant.now());
                paymentAttemptRepository.save(attempt);

                publishOutboxEvent(attempt.getTenantId(), attempt.getBranchId(), "PaymentFailed", attempt.getId().toString(),
                        Map.of("paymentAttemptId", attempt.getId().toString(), "resultCode", resultCode));
            }
        } catch (Exception e) {
            throw new RuntimeException("Error processing Daraja callback: " + e.getMessage(), e);
        }
    }

    private void publishOutboxEvent(UUID tenantId, UUID branchId, String eventType, String aggregateId, Object payloadObj) {
        try {
            String payloadJson = objectMapper.writeValueAsString(payloadObj);
            OutboxEvent event = OutboxEvent.builder()
                    .eventId(UUID.randomUUID().toString())
                    .eventType(eventType)
                    .tenantId(tenantId)
                    .branchId(branchId)
                    .aggregateId(aggregateId)
                    .payload(payloadJson)
                    .occurredAt(Instant.now())
                    .processed(false)
                    .build();
            outboxEventRepository.save(event);
        } catch (Exception e) {
            // Logging
        }
    }
}
