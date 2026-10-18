package com.trixx.smarttrolley.controller;

import com.trixx.smarttrolley.domain.*;
import com.trixx.smarttrolley.dto.ApiDtos.*;
import com.trixx.smarttrolley.repository.UserRepository;
import com.trixx.smarttrolley.service.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class TrixxApiController {

    private final TrolleyDeviceService trolleyDeviceService;
    private final ShoppingSessionAndBasketService sessionService;
    private final PaymentAndExitService paymentAndExitService;
    private final ManagementAndTheftPreventionService managementService;
    private final UserRepository userRepository;

    public TrixxApiController(TrolleyDeviceService trolleyDeviceService,
                              ShoppingSessionAndBasketService sessionService,
                              PaymentAndExitService paymentAndExitService,
                              ManagementAndTheftPreventionService managementService,
                              UserRepository userRepository) {
        this.trolleyDeviceService = trolleyDeviceService;
        this.sessionService = sessionService;
        this.paymentAndExitService = paymentAndExitService;
        this.managementService = managementService;
        this.userRepository = userRepository;
    }

    @PostMapping("/trolleys/claim")
    public ResponseEntity<ShoppingSession> claimTrolley(@RequestBody TrolleyClaimRequest req) {
        TrolleyDevice device = trolleyDeviceService.claimTrolleyByQr(req.qrCodeHash());
        User customer = null;
        if (req.customerId() != null) {
            customer = userRepository.findById(req.customerId()).orElse(null);
        }
        ShoppingSession session = sessionService.createOrGetSession(device.getId(), customer);
        return ResponseEntity.ok(session);
    }

    @PostMapping("/device-events/scans")
    public ResponseEntity<ShoppingBasket> recordScan(@RequestBody ScanEventRequest req) {
        trolleyDeviceService.recordDeviceEvent(
                req.eventId(), req.deviceCode(), req.sessionId(),
                "SCAN", req.barcode(), req.sequenceNumber(), req.timestamp(), req.rawPayload()
        );
        ShoppingBasket basket = sessionService.processScanEvent(req.sessionId(), req.barcode());
        return ResponseEntity.ok(basket);
    }

    @PostMapping("/device-events/removals")
    public ResponseEntity<ShoppingBasket> recordRemoval(@RequestBody RemovalEventRequest req) {
        trolleyDeviceService.recordDeviceEvent(
                req.eventId(), req.deviceCode(), req.sessionId(),
                "REMOVAL", req.barcode(), req.sequenceNumber(), null, null
        );
        ShoppingBasket basket = sessionService.processRemovalEvent(req.sessionId(), req.barcode());
        return ResponseEntity.ok(basket);
    }

    @PostMapping("/shopping-sessions/{sessionId}/checkout")
    public ResponseEntity<Order> createCheckout(@PathVariable("sessionId") Long sessionId) {
        Order order = sessionService.createCheckoutSnapshot(sessionId);
        return ResponseEntity.ok(order);
    }

    @PostMapping("/orders/{orderId}/payments/mpesa")
    public ResponseEntity<PaymentAttempt> initiateMpesa(@PathVariable("orderId") Long orderId, @RequestBody PaymentInitiationRequest req) {
        PaymentAttempt attempt = paymentAndExitService.initiateMpesaStkPush(orderId, req.phoneNumber());
        return ResponseEntity.ok(attempt);
    }

    @PostMapping("/webhooks/daraja/stk")
    public ResponseEntity<Map<String, String>> darajaCallback(@RequestBody MpesaCallbackPayload payload) {
        paymentAndExitService.processMpesaCallback(
                payload.checkoutRequestId(),
                payload.resultCode(),
                payload.resultDesc(),
                payload.mpesaReceiptNumber()
        );
        return ResponseEntity.ok(Map.of("ResultCode", "0", "ResultDesc", "Accepted"));
    }

    @GetMapping("/orders/{orderId}/receipt")
    public ResponseEntity<Receipt> getReceipt(@PathVariable("orderId") Long orderId) {
        Receipt receipt = paymentAndExitService.getReceiptByOrder(orderId);
        return ResponseEntity.ok(receipt);
    }

    @GetMapping("/orders/{orderId}/exit-token")
    public ResponseEntity<ExitToken> getExitToken(@PathVariable("orderId") Long orderId) {
        ExitToken token = paymentAndExitService.getExitTokenByOrder(orderId);
        return ResponseEntity.ok(token);
    }

    @PostMapping("/exit/redeem")
    public ResponseEntity<Map<String, Object>> redeemExitToken(@RequestBody ExitVerificationRequest req) {
        boolean success = paymentAndExitService.verifyAndRedeemExitToken(req.tokenHash());
        return ResponseEntity.ok(Map.of("verified", success, "message", "Exit token successfully verified and redeemed"));
    }

    @PostMapping("/verification/weight")
    public ResponseEntity<Map<String, Object>> verifyWeight(@RequestBody WeightVerificationRequest req) {
        Map<String, Object> result = managementService.verifyWeightDiscrepancy(req.basketId(), req.measuredWeightGrams());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/admin/overrides")
    public ResponseEntity<Map<String, String>> supervisorOverride(@RequestBody SupervisorOverrideRequest req) {
        managementService.recordSupervisorOverride(req.branchId(), req.supervisorId(), req.resourceType(), req.resourceId(), req.reason());
        return ResponseEntity.ok(Map.of("status", "SUCCESS", "message", "Override recorded in audit ledger"));
    }

    @GetMapping("/admin/branches/{branchId}/dashboard")
    public ResponseEntity<Map<String, Object>> getBranchDashboard(@PathVariable("branchId") Long branchId) {
        Map<String, Object> metrics = managementService.getBranchDashboardMetrics(branchId);
        return ResponseEntity.ok(metrics);
    }
}
