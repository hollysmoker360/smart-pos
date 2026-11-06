package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.Branch;
import com.trixx.scanflow.service.BasketEventPublisher;
import com.trixx.scanflow.service.ShoppingSessionService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/public")
public class PublicShoppingController {
    private static final String SESSION_TOKEN_HEADER = "X-Shopping-Session-Token";

    private final ShoppingSessionService shoppingSessionService;
    private final BasketEventPublisher basketEventPublisher;

    public PublicShoppingController(ShoppingSessionService shoppingSessionService,
                                    BasketEventPublisher basketEventPublisher) {
        this.shoppingSessionService = shoppingSessionService;
        this.basketEventPublisher = basketEventPublisher;
    }

    @GetMapping("/branches/{branchId}")
    public ResponseEntity<PublicBranchResponse> getBranch(@PathVariable UUID branchId) {
        Branch branch = shoppingSessionService.findPublicBranch(branchId);
        return ResponseEntity.ok(new PublicBranchResponse(
                branch.getId().toString(),
                branch.getName(),
                branch.getCurrency(),
                branch.isPhoneScanningEnabled(),
                branch.isGuestCheckoutEnabled()));
    }

    @PostMapping("/branches/{branchId}/shopping-sessions")
    public ResponseEntity<ShoppingSessionService.GuestSessionResponse> createGuestSession(
            @PathVariable UUID branchId) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(shoppingSessionService.createGuestSession(branchId));
    }

    @PostMapping("/shopping-sessions/{sessionId}/items")
    public ResponseEntity<ShoppingSessionService.BasketResponse> addItem(
            @PathVariable UUID sessionId,
            @RequestHeader(name = SESSION_TOKEN_HEADER, required = false) String accessToken,
            @Valid @RequestBody AddItemRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(shoppingSessionService.addGuestItem(
                sessionId,
                accessToken,
                new ShoppingSessionService.AddBasketItemRequest(request.productIdentifier(), request.quantity())));
    }

    @PatchMapping("/shopping-sessions/{sessionId}/items/{itemId}")
    public ResponseEntity<ShoppingSessionService.BasketResponse> updateItem(
            @PathVariable UUID sessionId,
            @PathVariable UUID itemId,
            @RequestHeader(name = SESSION_TOKEN_HEADER, required = false) String accessToken,
            @Valid @RequestBody UpdateItemRequest request) {
        return ResponseEntity.ok(shoppingSessionService.updateGuestItem(
                sessionId, accessToken, itemId, request.quantity()));
    }

    @DeleteMapping("/shopping-sessions/{sessionId}/items/{itemId}")
    public ResponseEntity<ShoppingSessionService.BasketResponse> removeItem(
            @PathVariable UUID sessionId,
            @PathVariable UUID itemId,
            @RequestHeader(name = SESSION_TOKEN_HEADER, required = false) String accessToken) {
        return ResponseEntity.ok(shoppingSessionService.removeGuestItem(sessionId, accessToken, itemId));
    }

    @GetMapping("/shopping-sessions/{sessionId}/basket")
    public ResponseEntity<ShoppingSessionService.BasketResponse> getBasket(
            @PathVariable UUID sessionId,
            @RequestHeader(name = SESSION_TOKEN_HEADER, required = false) String accessToken) {
        return ResponseEntity.ok(shoppingSessionService.getGuestBasket(sessionId, accessToken));
    }

    @GetMapping(value = "/shopping-sessions/{sessionId}/events", produces = "text/event-stream")
    public SseEmitter subscribeToBasket(
            @PathVariable UUID sessionId,
            @RequestHeader(name = SESSION_TOKEN_HEADER, required = false) String accessToken) {
        ShoppingSessionService.BasketResponse snapshot =
                shoppingSessionService.getGuestBasket(sessionId, accessToken);
        return basketEventPublisher.subscribe(sessionId, snapshot);
    }

    public record AddItemRequest(@NotBlank String productIdentifier, @NotNull @Positive Integer quantity) {}
    public record UpdateItemRequest(@NotNull @Positive Integer quantity) {}
    public record PublicBranchResponse(String id, String name, String currency, boolean phoneScanningEnabled,
                                       boolean guestCheckoutEnabled) {}
}
