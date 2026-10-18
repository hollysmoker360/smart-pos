package com.trixx.smartpos.controller;

import com.trixx.smartpos.model.Order;
import com.trixx.smartpos.model.PaymentAttempt;
import com.trixx.smartpos.service.CheckoutPaymentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/v1")
public class CheckoutPaymentController {

    private final CheckoutPaymentService checkoutPaymentService;

    public CheckoutPaymentController(CheckoutPaymentService checkoutPaymentService) {
        this.checkoutPaymentService = checkoutPaymentService;
    }

    @PostMapping("/orders/checkout")
    public ResponseEntity<Order> checkout(@RequestBody Map<String, String> body) {
        String sessionIdStr = body.get("sessionId");
        if (sessionIdStr == null) {
            throw new IllegalArgumentException("Session ID is required for checkout");
        }
        Order order = checkoutPaymentService.checkout(UUID.fromString(sessionIdStr));
        return ResponseEntity.ok(order);
    }

    @PostMapping("/orders/{id}/payments/mpesa")
    public ResponseEntity<PaymentAttempt> initiatePayment(
            @PathVariable UUID id,
            @RequestBody Map<String, String> body) {
        String phoneNumber = body.get("phoneNumber");
        if (phoneNumber == null) {
            throw new IllegalArgumentException("Phone number is required for M-Pesa payment");
        }
        PaymentAttempt attempt = checkoutPaymentService.initiateMpesaPayment(id, phoneNumber);
        return ResponseEntity.ok(attempt);
    }

    @PostMapping("/webhooks/daraja/stk")
    public ResponseEntity<Map<String, Object>> darajaCallback(@RequestBody Map<String, Object> callbackData) {
        checkoutPaymentService.processDarajaCallback(callbackData);
        Map<String, Object> response = new HashMap<>();
        response.put("ResultCode", 0);
        response.put("ResultDesc", "Accepted");
        return ResponseEntity.ok(response);
    }
}
