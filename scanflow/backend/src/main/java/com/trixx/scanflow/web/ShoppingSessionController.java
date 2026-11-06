package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.ShoppingSession;
import com.trixx.scanflow.security.CustomUserPrincipal;
import com.trixx.scanflow.service.ShoppingSessionService;
import com.trixx.scanflow.service.BasketEventPublisher;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/shopping-sessions")
public class ShoppingSessionController {
    private final ShoppingSessionService shoppingSessionService;
    private final BasketEventPublisher basketEventPublisher;

    public ShoppingSessionController(ShoppingSessionService shoppingSessionService,
                                     BasketEventPublisher basketEventPublisher) {
        this.shoppingSessionService = shoppingSessionService;
        this.basketEventPublisher = basketEventPublisher;
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'BUSINESS_ADMIN', 'BRANCH_MANAGER', 'CASHIER', 'CUSTOMER')")
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
    @PreAuthorize("hasAnyRole('OWNER', 'BUSINESS_ADMIN', 'BRANCH_MANAGER', 'CASHIER', 'CUSTOMER')")
    public ResponseEntity<ShoppingSessionService.BasketResponse> addItem(
            @AuthenticationPrincipal CustomUserPrincipal principal,
            @PathVariable UUID sessionId,
            @RequestBody ShoppingSessionService.AddBasketItemRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(shoppingSessionService.addItem(
            principal.getUser().getBusiness(), principal.getUser(), sessionId, request));
    }

    @GetMapping("/{sessionId}/basket")
    @PreAuthorize("hasAnyRole('OWNER', 'BUSINESS_ADMIN', 'BRANCH_MANAGER', 'CASHIER', 'CUSTOMER')")
    public ResponseEntity<ShoppingSessionService.BasketResponse> getBasket(
            @AuthenticationPrincipal CustomUserPrincipal principal,
            @PathVariable UUID sessionId) {
        return ResponseEntity.ok(shoppingSessionService.getBasket(principal.getUser().getBusiness(), principal.getUser(), sessionId));
    }

    @GetMapping(value = "/{sessionId}/events", produces = "text/event-stream")
    @PreAuthorize("hasAnyRole('OWNER', 'BUSINESS_ADMIN', 'BRANCH_MANAGER', 'CASHIER', 'CUSTOMER')")
    public SseEmitter subscribeToBasket(
            @AuthenticationPrincipal CustomUserPrincipal principal,
            @PathVariable UUID sessionId) {
        ShoppingSessionService.BasketResponse snapshot = shoppingSessionService.getBasket(
                principal.getUser().getBusiness(), principal.getUser(), sessionId);
        return basketEventPublisher.subscribe(sessionId, snapshot);
    }

    public record SessionResponse(String id, String sessionType, String status, BigDecimal totalAmount,
                                  Instant expiresAt) {}
}