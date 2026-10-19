package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.security.CustomUserPrincipal;
import com.trixx.scanflow.service.PosCheckoutService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
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

    @PostMapping("/pos/checkouts")
    public ResponseEntity<CheckoutResponse> checkout(@AuthenticationPrincipal CustomUserPrincipal principal,
                                                    @RequestBody PosCheckoutService.PosCheckoutRequest request) {
        Business business = principal.getUser().getBusiness();
        PosCheckoutService.PosCheckoutResponse response = posCheckoutService.checkout(business, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(new CheckoutResponse(
                response.items().stream().map(item -> new CheckoutItemResponse(
                        item.productId(),
                        item.name(),
                        item.quantity(),
                        item.unitPrice(),
                        item.lineTotal()
                )).toList(),
                response.totalAmount(),
                response.itemCount()
        ));
    }

    public record CheckoutResponse(List<CheckoutItemResponse> items, double totalAmount, int itemCount) {}
    public record CheckoutItemResponse(String productId, String name, Integer quantity, BigDecimal unitPrice, BigDecimal lineTotal) {}
}
