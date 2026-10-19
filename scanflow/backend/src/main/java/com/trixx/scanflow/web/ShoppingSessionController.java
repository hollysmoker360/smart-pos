package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.ShoppingSession;
import com.trixx.scanflow.security.CustomUserPrincipal;
import com.trixx.scanflow.service.ShoppingSessionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/shopping-sessions")
public class ShoppingSessionController {
    private final ShoppingSessionService shoppingSessionService;

    public ShoppingSessionController(ShoppingSessionService shoppingSessionService) {
        this.shoppingSessionService = shoppingSessionService;
    }

    @PostMapping
    public ResponseEntity<SessionResponse> createSession(
            @AuthenticationPrincipal CustomUserPrincipal principal,
            @RequestBody ShoppingSessionService.CreateSessionRequest request) {
        Business business = principal.getUser().getBusiness();
        ShoppingSession session = shoppingSessionService.createSession(business, principal.getUser(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(new SessionResponse(
                session.getId().toString(), session.getSessionType(), session.getStatus(),
                session.getTotalAmount(), session.getExpiresAt()));
    }

    @PostMapping("/{sessionId}/items")
    public ResponseEntity<ShoppingSessionService.BasketResponse> addItem(
            @AuthenticationPrincipal CustomUserPrincipal principal,
            @PathVariable UUID sessionId,
            @RequestBody ShoppingSessionService.AddBasketItemRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(shoppingSessionService.addItem(
                principal.getUser().getBusiness(), sessionId, request));
    }

    @GetMapping("/{sessionId}/basket")
    public ResponseEntity<ShoppingSessionService.BasketResponse> getBasket(
            @AuthenticationPrincipal CustomUserPrincipal principal,
            @PathVariable UUID sessionId) {
        return ResponseEntity.ok(shoppingSessionService.getBasket(principal.getUser().getBusiness(), sessionId));
    }

    public record SessionResponse(String id, String sessionType, String status, BigDecimal totalAmount,
                                  Instant expiresAt) {}
}