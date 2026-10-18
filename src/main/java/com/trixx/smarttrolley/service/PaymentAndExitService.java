package com.trixx.smarttrolley.service;

import com.trixx.smarttrolley.domain.*;
import com.trixx.smarttrolley.repository.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.UUID;

@Service
public class PaymentAndExitService {

    private final OrderRepository orderRepository;
    private final PaymentAttemptRepository paymentAttemptRepository;
    private final ReceiptRepository receiptRepository;
    private final ExitTokenRepository exitTokenRepository;
    private final ShoppingSessionRepository sessionRepository;
    private final TrolleyDeviceRepository trolleyRepository;

    @Value("${trixx.mpesa.shortcode:174379}")
    private String mpesaShortcode;

    public PaymentAndExitService(OrderRepository orderRepository,
                                 PaymentAttemptRepository paymentAttemptRepository,
                                 ReceiptRepository receiptRepository,
                                 ExitTokenRepository exitTokenRepository,
                                 ShoppingSessionRepository sessionRepository,
                                 TrolleyDeviceRepository trolleyRepository) {
        this.orderRepository = orderRepository;
        this.paymentAttemptRepository = paymentAttemptRepository;
        this.receiptRepository = receiptRepository;
        this.exitTokenRepository = exitTokenRepository;
        this.sessionRepository = sessionRepository;
        this.trolleyRepository = trolleyRepository;
    }

    @Transactional
    public PaymentAttempt initiateMpesaStkPush(Long orderId, String phoneNumber) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("ORDER_NOT_FOUND: Order ID not found"));

        if ("PAID".equals(order.getOrderStatus()) || "EXIT_AUTHORIZED".equals(order.getOrderStatus())) {
            throw new IllegalStateException("ORDER_ALREADY_PAID: Order is already paid");
        }

        order.setOrderStatus("PAYMENT_PENDING");
        orderRepository.save(order);

        String checkoutRequestId = "ws_CO_" + UUID.randomUUID().toString().replace("-", "").substring(0, 16);
        String merchantRequestId = "MR-" + UUID.randomUUID().toString().replace("-", "").substring(0, 12);
        String paymentRef = "PAY-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        PaymentAttempt attempt = new PaymentAttempt();
        attempt.setOrder(order);
        attempt.setPaymentReference(paymentRef);
        attempt.setProvider("M_PESA");
        attempt.setPhoneNumber(phoneNumber);
        attempt.setAmount(order.getTotalAmount());
        attempt.setCheckoutRequestId(checkoutRequestId);
        attempt.setMerchantRequestId(merchantRequestId);
        attempt.setStatus("PENDING");
        attempt.setCreatedAt(LocalDateTime.now());
        attempt.setUpdatedAt(LocalDateTime.now());

        return paymentAttemptRepository.save(attempt);
    }

    @Transactional
    public void processMpesaCallback(String checkoutRequestId, int resultCode, String resultDesc, String mpesaReceiptNumber) {
        var attemptOpt = paymentAttemptRepository.findByCheckoutRequestId(checkoutRequestId);
        if (attemptOpt.isEmpty()) {
            return;
        }

        PaymentAttempt attempt = attemptOpt.get();
        if ("SUCCESS".equalsIgnoreCase(attempt.getStatus())) {
            return;
        }

        Order order = attempt.getOrder();

        if (resultCode == 0) {
            attempt.setStatus("SUCCESS");
            attempt.setUpdatedAt(LocalDateTime.now());
            paymentAttemptRepository.save(attempt);

            order.setOrderStatus("PAID");
            orderRepository.save(order);

            generateReceiptAndExitToken(order);

            ShoppingSession session = order.getSession();
            if (session != null) {
                session.setSessionStatus("COMPLETED");
                session.setEndedAt(LocalDateTime.now());
                sessionRepository.save(session);

                TrolleyDevice trolley = session.getTrolley();
                if (trolley != null) {
                    trolley.setDeviceStatus("AVAILABLE");
                    trolleyRepository.save(trolley);
                }
            }
        } else {
            attempt.setStatus("FAILED");
            attempt.setUpdatedAt(LocalDateTime.now());
            paymentAttemptRepository.save(attempt);

            order.setOrderStatus("PAYMENT_FAILED");
            orderRepository.save(order);
        }
    }

    @Transactional
    public Receipt getReceiptByOrder(Long orderId) {
        return receiptRepository.findByOrderId(orderId)
                .orElseThrow(() -> new IllegalArgumentException("RECEIPT_NOT_FOUND: Receipt not generated for order " + orderId));
    }

    @Transactional
    public ExitToken getExitTokenByOrder(Long orderId) {
        return exitTokenRepository.findByOrderId(orderId)
                .orElseThrow(() -> new IllegalArgumentException("EXIT_TOKEN_NOT_FOUND: Exit token not found for order " + orderId));
    }

    @Transactional
    public boolean verifyAndRedeemExitToken(String tokenHash) {
        ExitToken exitToken = exitTokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new IllegalArgumentException("EXIT_TOKEN_INVALID: Exit token hash is invalid"));

        if (!"VALID".equals(exitToken.getStatus())) {
            throw new IllegalStateException("EXIT_TOKEN_ALREADY_USED: Token state is " + exitToken.getStatus());
        }

        if (exitToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            exitToken.setStatus("EXPIRED");
            exitTokenRepository.save(exitToken);
            throw new IllegalStateException("EXIT_TOKEN_EXPIRED: Token has expired");
        }

        exitToken.setStatus("REDEEMED");
        exitToken.setRedeemedAt(LocalDateTime.now());
        exitTokenRepository.save(exitToken);

        Order order = exitToken.getOrder();
        order.setOrderStatus("EXIT_AUTHORIZED");
        orderRepository.save(order);

        return true;
    }

    private void generateReceiptAndExitToken(Order order) {
        String receiptNum = "RCT-" + order.getBranch().getCode() + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        Receipt receipt = new Receipt();
        receipt.setOrder(order);
        receipt.setReceiptNumber(receiptNum);
        receipt.setQrCodeData("TRIXX-RECEIPT-DATA:" + receiptNum + ":" + order.getTotalAmount());
        receipt.setIssuedAt(LocalDateTime.now());
        receipt.setStatus("ISSUED");
        receiptRepository.save(receipt);

        String rawToken = "EXIT-" + order.getOrderNumber() + "-" + System.currentTimeMillis() + "-" + UUID.randomUUID();
        String hash = sha256Hex(rawToken);

        ExitToken exitToken = new ExitToken();
        exitToken.setOrder(order);
        exitToken.setTokenHash(hash);
        exitToken.setExpiresAt(LocalDateTime.now().plusMinutes(30));
        exitToken.setStatus("VALID");
        exitTokenRepository.save(exitToken);
    }

    private String sha256Hex(String text) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(text.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
}
