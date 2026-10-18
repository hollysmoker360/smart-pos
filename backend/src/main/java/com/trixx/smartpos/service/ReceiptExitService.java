package com.trixx.smartpos.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.trixx.smartpos.model.*;
import com.trixx.smartpos.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
public class ReceiptExitService {

    private final OrderRepository orderRepository;
    private final ReceiptRepository receiptRepository;
    private final ExitTokenRepository exitTokenRepository;
    private final ExitEventRepository exitEventRepository;
    private final OutboxEventRepository outboxEventRepository;
    private final ObjectMapper objectMapper;

    public ReceiptExitService(
            OrderRepository orderRepository,
            ReceiptRepository receiptRepository,
            ExitTokenRepository exitTokenRepository,
            ExitEventRepository exitEventRepository,
            OutboxEventRepository outboxEventRepository,
            ObjectMapper objectMapper) {
        this.orderRepository = orderRepository;
        this.receiptRepository = receiptRepository;
        this.exitTokenRepository = exitTokenRepository;
        this.exitEventRepository = exitEventRepository;
        this.outboxEventRepository = outboxEventRepository;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public Receipt generateReceipt(UUID orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        if (!"PAID".equalsIgnoreCase(order.getStatus())) {
            throw new IllegalStateException("Receipt can only be generated for PAID orders");
        }

        return receiptRepository.findByOrderId(orderId)
                .orElseGet(() -> {
                    Receipt receipt = Receipt.builder()
                            .tenantId(order.getTenantId())
                            .branchId(order.getBranchId())
                            .orderId(order.getId())
                            .receiptNumber("REC-" + System.currentTimeMillis())
                            .totalAmount(order.getTotalAmount())
                            .createdAt(Instant.now())
                            .build();
                    Receipt saved = receiptRepository.save(receipt);

                    // Generate single-use Exit Pass
                    String tokenHash = "EXIT-" + UUID.randomUUID().toString();
                    ExitToken exitToken = ExitToken.builder()
                            .tenantId(order.getTenantId())
                            .branchId(order.getBranchId())
                            .orderId(order.getId())
                            .tokenHash(tokenHash)
                            .status("ELIGIBLE")
                            .expiresAt(Instant.now().plus(2, ChronoUnit.HOURS))
                            .createdAt(Instant.now())
                            .build();
                    exitTokenRepository.save(exitToken);

                    return saved;
                });
    }

    public ExitToken getExitTokenForOrder(UUID orderId) {
        return exitTokenRepository.findByOrderId(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Exit pass token not found for order: " + orderId));
    }

    @Transactional
    public Map<String, Object> verifyExitToken(String tokenHash) {
        ExitToken token = exitTokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new IllegalArgumentException("Invalid or unrecognized Exit Pass token"));

        Map<String, Object> result = new HashMap<>();
        result.put("tokenId", token.getId());
        result.put("orderId", token.getOrderId());
        result.put("status", token.getStatus());
        result.put("expiresAt", token.getExpiresAt());

        boolean isValid = "ELIGIBLE".equals(token.getStatus()) && Instant.now().isBefore(token.getExpiresAt());
        result.put("valid", isValid);

        Order order = orderRepository.findById(token.getOrderId()).orElseThrow();
        result.put("orderNumber", order.getOrderNumber());
        result.put("totalAmount", order.getTotalAmount());

        // Check if random inspection is required (e.g. 10% chance)
        boolean randomInspection = Math.random() < 0.15;
        result.put("inspectionRequired", randomInspection);

        return result;
    }

    @Transactional
    public ExitEvent completeExit(String tokenHash, UUID staffUserId, boolean inspectionPerformed, String notes) {
        ExitToken token = exitTokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new IllegalArgumentException("Exit Pass token not found"));

        if (!"ELIGIBLE".equals(token.getStatus())) {
            throw new IllegalStateException("Exit pass token is no longer eligible (Status: " + token.getStatus() + ")");
        }

        if (Instant.now().isAfter(token.getExpiresAt())) {
            token.setStatus("EXPIRED");
            exitTokenRepository.save(token);
            throw new IllegalStateException("Exit pass token has expired");
        }

        // Atomically mark token as USED
        token.setStatus("USED");
        token.setUsedAt(Instant.now());
        exitTokenRepository.save(token);

        ExitEvent event = ExitEvent.builder()
                .exitTokenId(token.getId())
                .branchId(token.getBranchId())
                .staffUserId(staffUserId)
                .result("APPROVED")
                .inspectionPerformed(inspectionPerformed)
                .notes(notes)
                .createdAt(Instant.now())
                .build();

        ExitEvent saved = exitEventRepository.save(event);

        Order order = orderRepository.findById(token.getOrderId()).orElseThrow();
        order.setStatus("EXIT_APPROVED");
        order.setUpdatedAt(Instant.now());
        orderRepository.save(order);

        publishOutboxEvent(token.getTenantId(), token.getBranchId(), "ExitApproved", token.getId().toString(),
                Map.of("exitTokenId", token.getId().toString(), "orderId", token.getOrderId().toString()));

        return saved;
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
