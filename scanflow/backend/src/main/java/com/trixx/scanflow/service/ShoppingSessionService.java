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
import org.springframework.security.access.AccessDeniedException;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.time.Duration;
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
    private final InvitationTokenCodec invitationTokenCodec;

    public ShoppingSessionService(ShoppingSessionRepository sessionRepository,
                                  BasketItemRepository basketItemRepository,
                                  BranchRepository branchRepository,
                                  ProductCatalogService productCatalogService,
                                  BranchAccessService branchAccessService,
                                  BasketEventPublisher basketEventPublisher,
                                  InvitationTokenCodec invitationTokenCodec) {
        this.sessionRepository = sessionRepository;
        this.basketItemRepository = basketItemRepository;
        this.branchRepository = branchRepository;
        this.productCatalogService = productCatalogService;
        this.branchAccessService = branchAccessService;
        this.basketEventPublisher = basketEventPublisher;
        this.invitationTokenCodec = invitationTokenCodec;
    }

    @Transactional
    public ShoppingSession createSession(Business business, User user, CreateSessionRequest request) {
        if (request.branchName() == null || request.branchName().isBlank()) {
            throw new IllegalArgumentException("Branch name is required");
        }
        Branch branch = branchRepository.findByBusinessAndName(business, request.branchName().trim());
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
    public GuestSessionResponse createGuestSession(UUID branchId) {
        Branch branch = branchRepository.findById(branchId)
                .filter(Branch::isActive)
                .orElseThrow(() -> new IllegalArgumentException("Active branch not found"));
        if (!branch.isPhoneScanningEnabled()) {
            throw new IllegalArgumentException("Phone scanning is not enabled for this branch");
        }
        if (!branch.isGuestCheckoutEnabled()) {
            throw new IllegalArgumentException("Guest shopping is not enabled for this branch");
        }

        String accessToken = invitationTokenCodec.issueToken();
        ShoppingSession session = new ShoppingSession(
                branch.getBusiness(), branch, null, "PHONE_SCANNING");
        session.setGuestAccessTokenHash(invitationTokenCodec.hash(accessToken));
        session.setExpiresAt(Instant.now().plus(Duration.ofHours(4)));
        session = sessionRepository.save(session);
        publishAfterCommit(session.getId(), buildBasketSnapshot(session));
        return new GuestSessionResponse(
                session.getId().toString(),
                accessToken,
                branch.getId().toString(),
                branch.getName(),
                branch.getCurrency(),
                branch.isGuestCheckoutEnabled(),
                session.getExpiresAt());
    }

    @Transactional
    public BasketResponse addItem(Business business, User user, UUID sessionId, AddBasketItemRequest request) {
        ShoppingSession session = getActiveSession(business, user, sessionId);
        return addItem(session, request);
    }

    @Transactional
    public BasketResponse addGuestItem(UUID sessionId, String accessToken, AddBasketItemRequest request) {
        return addItem(getGuestSession(sessionId, accessToken), request);
    }

    @Transactional
    public BasketResponse updateGuestItem(UUID sessionId, String accessToken, UUID itemId, int quantity) {
        ShoppingSession session = getGuestSession(sessionId, accessToken);
        if (quantity < 1) {
            throw new IllegalArgumentException("Quantity must be greater than zero");
        }
        BasketItem item = basketItemRepository.findById(itemId)
                .filter(candidate -> candidate.getSession().getId().equals(sessionId))
                .orElseThrow(() -> new IllegalArgumentException("Basket item not found"));
        if (quantity > item.getProduct().getStockQuantity()) {
            throw new IllegalArgumentException("Requested quantity exceeds available stock");
        }
        item.setQuantity(quantity);
        item.setUpdatedAt(Instant.now());
        basketItemRepository.save(item);
        BasketResponse snapshot = buildBasketSnapshot(session);
        publishAfterCommit(sessionId, snapshot);
        return snapshot;
    }

    @Transactional
    public BasketResponse removeGuestItem(UUID sessionId, String accessToken, UUID itemId) {
        ShoppingSession session = getGuestSession(sessionId, accessToken);
        BasketItem item = basketItemRepository.findById(itemId)
                .filter(candidate -> candidate.getSession().getId().equals(sessionId))
                .orElseThrow(() -> new IllegalArgumentException("Basket item not found"));
        basketItemRepository.delete(item);
        BasketResponse snapshot = buildBasketSnapshot(session);
        publishAfterCommit(sessionId, snapshot);
        return snapshot;
    }

    private BasketResponse addItem(ShoppingSession session, AddBasketItemRequest request) {
        if (request.quantity() == null || request.quantity() < 1) {
            throw new IllegalArgumentException("Quantity must be greater than zero");
        }

        Product product = productCatalogService.findByBusinessAndIdentifier(
                session.getBusiness(), request.productIdentifier());
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
        publishAfterCommit(session.getId(), snapshot);
        return snapshot;
    }

    @Transactional(readOnly = true)
    public BasketResponse getBasket(Business business, User user, UUID sessionId) {
        ShoppingSession session = getActiveSession(business, user, sessionId);
        return buildBasketSnapshot(session);
    }

    @Transactional(readOnly = true)
    public BasketResponse getGuestBasket(UUID sessionId, String accessToken) {
        return buildBasketSnapshot(getGuestSession(sessionId, accessToken));
    }

    @Transactional(readOnly = true)
    public Branch findPublicBranch(UUID branchId) {
        return branchRepository.findById(branchId)
                .filter(Branch::isActive)
                .orElseThrow(() -> new IllegalArgumentException("Active branch not found"));
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
        sessionRepository.save(session);
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

    private ShoppingSession getGuestSession(UUID sessionId, String accessToken) {
        if (accessToken == null || accessToken.isBlank()) {
            throw new AccessDeniedException("A valid shopping session token is required");
        }
        ShoppingSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Shopping session not found"));
        String storedHash = session.getGuestAccessTokenHash();
        String suppliedHash = invitationTokenCodec.hash(accessToken.trim());
        if (storedHash == null || !MessageDigest.isEqual(
                storedHash.getBytes(StandardCharsets.US_ASCII),
                suppliedHash.getBytes(StandardCharsets.US_ASCII))) {
            throw new AccessDeniedException("Shopping session access denied");
        }
        if (!"ACTIVE".equals(session.getStatus())) {
            throw new IllegalArgumentException("Shopping session is not active");
        }
        if (session.getExpiresAt() == null || !session.getExpiresAt().isAfter(Instant.now())) {
            throw new IllegalArgumentException("Shopping session has expired");
        }
        return session;
    }

    public record CreateSessionRequest(String sessionType, String branchName) {}
    public record AddBasketItemRequest(String productIdentifier, Integer quantity) {}
    public record GuestSessionResponse(String sessionId, String accessToken, String branchId, String branchName,
                                       String currency, boolean guestCheckoutEnabled, Instant expiresAt) {}
    public record BasketLine(String id, String productId, String productSku, String productName,
                             Integer quantity, BigDecimal unitPrice, BigDecimal lineTotal) {}
    public record BasketResponse(String sessionId, List<BasketLine> items, BigDecimal totalAmount) {}
}