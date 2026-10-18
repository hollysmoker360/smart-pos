package com.trixx.smartpos.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.trixx.smartpos.model.*;
import com.trixx.smartpos.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

@Service
public class ShoppingSessionService {

    private final ShoppingSessionRepository sessionRepository;
    private final CatalogService catalogService;
    private final OutboxEventRepository outboxEventRepository;
    private final ObjectMapper objectMapper;

    public ShoppingSessionService(
            ShoppingSessionRepository sessionRepository,
            CatalogService catalogService,
            OutboxEventRepository outboxEventRepository,
            ObjectMapper objectMapper) {
        this.sessionRepository = sessionRepository;
        this.catalogService = catalogService;
        this.outboxEventRepository = outboxEventRepository;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public ShoppingSession createSession(UUID tenantId, UUID branchId, UUID customerId, String guestPhone) {
        ShoppingSession session = ShoppingSession.builder()
                .tenantId(tenantId)
                .branchId(branchId)
                .customerId(customerId)
                .guestPhone(guestPhone)
                .status("ACTIVE")
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        session = sessionRepository.save(session);
        publishOutboxEvent(tenantId, branchId, "ShoppingSessionCreated", session.getId().toString(), Map.of("sessionId", session.getId().toString()));
        return session;
    }

    public Optional<ShoppingSession> getSession(UUID sessionId) {
        return sessionRepository.findById(sessionId);
    }

    @Transactional
    public ShoppingSession addItemToBasket(UUID sessionId, String barcode, int quantity) {
        ShoppingSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Shopping session not found"));

        if (!"ACTIVE".equals(session.getStatus())) {
            throw new IllegalStateException("Shopping session is not active");
        }

        Product product = catalogService.resolveProductByBarcode(barcode)
                .orElseThrow(() -> new IllegalArgumentException("Product not found for barcode: " + barcode));

        BigDecimal price = catalogService.getEffectivePrice(session.getBranchId(), product.getId());

        Optional<ShoppingSessionItem> existingItemOpt = session.getItems().stream()
                .filter(item -> item.getProductId().equals(product.getId()))
                .findFirst();

        if (existingItemOpt.isPresent()) {
            ShoppingSessionItem item = existingItemOpt.get();
            item.setQuantity(item.getQuantity() + quantity);
            item.setTotalPrice(price.multiply(BigDecimal.valueOf(item.getQuantity())));
        } else {
            ShoppingSessionItem item = ShoppingSessionItem.builder()
                    .session(session)
                    .productId(product.getId())
                    .barcode(barcode)
                    .quantity(quantity)
                    .unitPrice(price)
                    .totalPrice(price.multiply(BigDecimal.valueOf(quantity)))
                    .build();
            session.getItems().add(item);
        }

        session.setUpdatedAt(Instant.now());
        sessionRepository.save(session);

        publishOutboxEvent(session.getTenantId(), session.getBranchId(), "BasketUpdated", session.getId().toString(),
                Map.of("sessionId", session.getId().toString(), "barcode", barcode, "quantity", quantity));

        return session;
    }

    @Transactional
    public ShoppingSession updateItemQuantity(UUID sessionId, UUID itemId, int newQuantity) {
        ShoppingSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Shopping session not found"));

        if (newQuantity <= 0) {
            session.getItems().removeIf(item -> item.getId().equals(itemId));
        } else {
            for (ShoppingSessionItem item : session.getItems()) {
                if (item.getId().equals(itemId)) {
                    item.setQuantity(newQuantity);
                    item.setTotalPrice(item.getUnitPrice().multiply(BigDecimal.valueOf(newQuantity)));
                    break;
                }
            }
        }
        session.setUpdatedAt(Instant.now());
        return sessionRepository.save(session);
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
