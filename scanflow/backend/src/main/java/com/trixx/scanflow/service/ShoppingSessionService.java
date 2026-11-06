package com.trixx.scanflow.service;

import com.trixx.scanflow.domain.BasketItem;
import com.trixx.scanflow.domain.Branch;
import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.Product;
import com.trixx.scanflow.domain.ShoppingSession;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.repository.BasketItemRepository;
import com.trixx.scanflow.repository.BranchRepository;
import com.trixx.scanflow.repository.ShoppingSessionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class ShoppingSessionService {
    private static final Logger log = LoggerFactory.getLogger(ShoppingSessionService.class);

    private final ShoppingSessionRepository sessionRepository;
    private final BasketItemRepository basketItemRepository;
    private final BranchRepository branchRepository;
    private final ProductCatalogService productCatalogService;
    private final BranchAccessService branchAccessService;
    private final BasketEventPublisher basketEventPublisher;

    public ShoppingSessionService(ShoppingSessionRepository sessionRepository,
                                  BasketItemRepository basketItemRepository,
                                  BranchRepository branchRepository,
                                  ProductCatalogService productCatalogService,
                                  BranchAccessService branchAccessService,
                                  BasketEventPublisher basketEventPublisher) {
        this.sessionRepository = sessionRepository;
        this.basketItemRepository = basketItemRepository;
        this.branchRepository = branchRepository;
        this.productCatalogService = productCatalogService;
        this.branchAccessService = branchAccessService;
        this.basketEventPublisher = basketEventPublisher;
    }

    @Transactional
    public ShoppingSession createSession(Business business, User user, CreateSessionRequest request) {
        String branchName = request.branchName() == null || request.branchName().isBlank()
                ? "Main Branch" : request.branchName();
        Branch branch = branchRepository.findByBusinessAndName(business, branchName);
        if (branch == null || !branch.isActive()) {
            throw new IllegalArgumentException("Active branch not found");
        }
        branchAccessService.requireBranchAccess(user, branch);
        if (request.sessionType() == null || request.sessionType().isBlank()) {
            throw new IllegalArgumentException("Session type is required");
        }

        ShoppingSession session = sessionRepository.save(new ShoppingSession(business, branch, user, request.sessionType()));
        publishAfterCommit(session.getId(), buildBasketSnapshot(session));
        return session;
    }

    @Transactional
    public BasketResponse addItem(Business business, User user, UUID sessionId, AddBasketItemRequest request) {
        ShoppingSession session = getActiveSession(business, user, sessionId);
        if (request.quantity() == null || request.quantity() < 1) {
            throw new IllegalArgumentException("Quantity must be greater than zero");
        }

        Product product = productCatalogService.findByBusinessAndIdentifier(business, request.productIdentifier());
        if (!product.isActive()) {
            throw new IllegalArgumentException("Product is not active");
        }

        BasketItem item = basketItemRepository.findBySessionAndProduct(session, product)
                .orElseGet(() -> new BasketItem(session, product, 0, product.getStandardPrice()));
        int updatedQuantity = item.getQuantity() + request.quantity();
        if (updatedQuantity > product.getStockQuantity()) {
            throw new IllegalArgumentException("Requested quantity exceeds available stock");
        }
        item.setQuantity(updatedQuantity);
        item.setUpdatedAt(Instant.now());
        basketItemRepository.save(item);

        BasketResponse snapshot = buildBasketSnapshot(session);
        publishAfterCommit(sessionId, snapshot);
        return snapshot;
    }

    @Transactional(readOnly = true)
    public BasketResponse getBasket(Business business, User user, UUID sessionId) {
        ShoppingSession session = getActiveSession(business, user, sessionId);
        return buildBasketSnapshot(session);
    }

    private BasketResponse buildBasketSnapshot(ShoppingSession session) {
        List<BasketLine> items = basketItemRepository.findBySession(session).stream()
                .map(item -> new BasketLine(
                        item.getId().toString(),
                        item.getProduct().getId().toString(),
                        item.getProduct().getSku(),
                        item.getProduct().getName(),
                        item.getQuantity(),
                        item.getUnitPrice(),
                        item.getLineTotal()
                )).toList();
        BigDecimal totalAmount = items.stream()
                .map(BasketLine::lineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        session.setTotalAmount(totalAmount);
        return new BasketResponse(session.getId().toString(), items, totalAmount);
    }

    private void publishAfterCommit(UUID sessionId, BasketResponse snapshot) {
        Runnable publish = () -> {
            try {
                basketEventPublisher.publish(sessionId, snapshot);
            } catch (RuntimeException exception) {
                log.error("Failed to publish basket snapshot for session {}", sessionId, exception);
            }
        };
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    publish.run();
                }
            });
        } else {
            publish.run();
        }
    }

    private ShoppingSession getActiveSession(Business business, User user, UUID sessionId) {
        ShoppingSession session = sessionRepository.findById(sessionId)
                .filter(candidate -> candidate.getBusiness().getId().equals(business.getId()))
                .orElseThrow(() -> new IllegalArgumentException("Shopping session not found"));
        branchAccessService.requireSessionAccess(user, session);
        if (!"ACTIVE".equals(session.getStatus())) {
            throw new IllegalArgumentException("Shopping session is not active");
        }
        if (session.getExpiresAt() != null && session.getExpiresAt().isBefore(Instant.now())) {
            throw new IllegalArgumentException("Shopping session has expired");
        }
        return session;
    }

    public record CreateSessionRequest(String sessionType, String branchName) {}
    public record AddBasketItemRequest(String productIdentifier, Integer quantity) {}
    public record BasketLine(String id, String productId, String productSku, String productName,
                             Integer quantity, BigDecimal unitPrice, BigDecimal lineTotal) {}
    public record BasketResponse(String sessionId, List<BasketLine> items, BigDecimal totalAmount) {}
}