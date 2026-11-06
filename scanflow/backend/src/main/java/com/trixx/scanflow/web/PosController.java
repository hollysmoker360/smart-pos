package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.security.CustomUserPrincipal;
import com.trixx.scanflow.service.PosCheckoutService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class PosController {
    private final PosCheckoutService posCheckoutService;

    public PosController(PosCheckoutService posCheckoutService) {
        this.posCheckoutService = posCheckoutService;
    }

    @PostMapping("/pos/quotes")
    @PreAuthorize("hasAnyRole('OWNER', 'BRANCH_MANAGER', 'CASHIER')")
    public ResponseEntity<PosCheckoutService.PosQuoteResponse> quote(
            @AuthenticationPrincipal CustomUserPrincipal principal,
            @Valid @RequestBody PosCheckoutService.PosQuoteRequest request) {
        Business business = principal.getUser().getBusiness();
        return ResponseEntity.ok(posCheckoutService.quote(business, principal.getUser(), request));
    }

    @PostMapping("/pos/checkouts")
    @PreAuthorize("hasAnyRole('OWNER', 'BRANCH_MANAGER', 'CASHIER')")
    public ResponseEntity<CheckoutResponse> checkout(@AuthenticationPrincipal CustomUserPrincipal principal,
                                                    @Valid @RequestBody PosCheckoutService.PosCheckoutRequest request) {
        Business business = principal.getUser().getBusiness();
        PosCheckoutService.PosCheckoutResponse response = posCheckoutService.checkout(business, principal.getUser(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(new CheckoutResponse(
                response.orderId(), response.orderNumber(), response.orderStatus(), response.paymentStatus(),
                response.paymentMethod(), response.currency(), response.items(), response.totalAmount(),
                response.itemCount(), response.cashReceived(), response.changeDue()
        ));
    }

    public record CheckoutResponse(String orderId, String orderNumber, String orderStatus, String paymentStatus,
                                   String paymentMethod, String currency,
                                   List<PosCheckoutService.PosCheckoutItemResponse> items,
                                   BigDecimal totalAmount, int itemCount, BigDecimal cashReceived,
                                   BigDecimal changeDue) {}
}
