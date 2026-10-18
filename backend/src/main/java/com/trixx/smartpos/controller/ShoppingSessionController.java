package com.trixx.smartpos.controller;

import com.trixx.smartpos.model.ShoppingSession;
import com.trixx.smartpos.security.TenantContext;
import com.trixx.smartpos.service.ShoppingSessionService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/v1/shopping-sessions")
public class ShoppingSessionController {

    private final ShoppingSessionService sessionService;

    public ShoppingSessionController(ShoppingSessionService sessionService) {
        this.sessionService = sessionService;
    }

    @PostMapping
    public ResponseEntity<ShoppingSession> createSession(@RequestBody Map<String, String> body) {
        String tenantIdStr = body.getOrDefault("tenantId", TenantContext.getTenantId());
        String branchIdStr = body.getOrDefault("branchId", TenantContext.getBranchId());
        String guestPhone = body.get("guestPhone");

        if (tenantIdStr == null || branchIdStr == null) {
            throw new IllegalArgumentException("Tenant ID and Branch ID are required to create a session");
        }

        ShoppingSession session = sessionService.createSession(
                UUID.fromString(tenantIdStr),
                UUID.fromString(branchIdStr),
                null,
                guestPhone
        );

        return ResponseEntity.ok(session);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ShoppingSession> getSession(@PathVariable UUID id) {
        ShoppingSession session = sessionService.getSession(id)
                .orElseThrow(() -> new IllegalArgumentException("Session not found: " + id));
        return ResponseEntity.ok(session);
    }

    @PostMapping("/{id}/items")
    public ResponseEntity<ShoppingSession> addItem(
            @PathVariable UUID id,
            @RequestBody Map<String, Object> body) {
        String barcode = (String) body.get("barcode");
        Integer quantity = body.containsKey("quantity") ? ((Number) body.get("quantity")).intValue() : 1;

        if (barcode == null) {
            throw new IllegalArgumentException("Barcode is required");
        }

        ShoppingSession session = sessionService.addItemToBasket(id, barcode, quantity);
        return ResponseEntity.ok(session);
    }

    @PutMapping("/{id}/items/{itemId}")
    public ResponseEntity<ShoppingSession> updateItemQuantity(
            @PathVariable UUID id,
            @PathVariable UUID itemId,
            @RequestBody Map<String, Object> body) {
        Integer quantity = ((Number) body.get("quantity")).intValue();
        ShoppingSession session = sessionService.updateItemQuantity(id, itemId, quantity);
        return ResponseEntity.ok(session);
    }
}
