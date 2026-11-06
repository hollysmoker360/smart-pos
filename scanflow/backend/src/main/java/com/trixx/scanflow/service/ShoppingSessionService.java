package com.trixx.scanflow.service;

import com.trixx.scanflow.domain.BasketItem;
import com.trixx.scanflow.domain.Branch;
import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.ExitToken;
import com.trixx.scanflow.domain.InventoryMovement;
import com.trixx.scanflow.domain.OrderItem;
import com.trixx.scanflow.domain.PaymentAttempt;
import com.trixx.scanflow.domain.Product;
import com.trixx.scanflow.domain.RetailOrder;
import com.trixx.scanflow.domain.ShoppingSession;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.repository.BasketItemRepository;
import com.trixx.scanflow.repository.BranchRepository;
import com.trixx.scanflow.repository.ExitTokenRepository;
import com.trixx.scanflow.repository.InventoryMovementRepository;
import com.trixx.scanflow.repository.PaymentAttemptRepository;
import com.trixx.scanflow.repository.RetailOrderRepository;
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
import java.util.Optional;
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
    private final RetailOrderRepository retailOrderRepository;
    private final PaymentAttemptRepository paymentAttemptRepository;
    private final InventoryMovementRepository inventoryMovementRepository;
    private final ExitTokenRepository exitTokenRepository;
    private final AuditLogService auditLogService;

    public ShoppingSessionService(ShoppingSessionRepository sessionRepository,
                                  BasketItemRepository basketItemRepository,
                                  BranchRepository branchRepository,
                                  ProductCatalogService productCatalogService,
                                  BranchAccessService branchAccessService,
                                  BasketEventPublisher basketEventPublisher,
                                  InvitationTokenCodec invitationTokenCodec,
                                  RetailOrderRepository retailOrderRepository,
                                  PaymentAttemptRepository paymentAttemptRepository,
                                  InventoryMovementRepository inventoryMovementRepository,
                                  ExitTokenRepository exitTokenRepository,
                                  AuditLogService auditLogService) {
        this.sessionRepository = sessionRepository;
        this.basketItemRepository = basketItemRepository;
        this.branchRepository = branchRepository;
        this.productCatalogService = productCatalogService;
        this.branchAccessService = branchAccessService;
        this.basketEventPublisher = basketEventPublisher;
        this.invitationTokenCodec = invitationTokenCodec;
        this.retailOrderRepository = retailOrderRepository;
        this.paymentAttemptRepository = paymentAttemptRepository;
        this.inventoryMovementRepository = inventoryMovementRepository;
        this.exitTokenRepository = exitTokenRepository;
        this.auditLogService = auditLogService;
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
    public GuestCheckoutResponse checkoutGuestSession(UUID sessionId, String accessToken,
                                                     GuestCheckoutRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Checkout request is required");
        }
        ShoppingSession session = getGuestSession(sessionId, accessToken);
        List<BasketItem> basketItems = basketItemRepository.findBySession(session);
        if (basketItems.isEmpty()) {
            throw new IllegalArgumentException("Basket is empty");
        }

        BigDecimal totalAmount = basketItems.stream()
                .map(BasketItem::getLineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        if (totalAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Basket total must be greater than zero");
        }

        String paymentMethod = normalizePaymentMethod(request.paymentMethod());
        String idempotencyKey = request.idempotencyKey() == null || request.idempotencyKey().isBlank()
                ? sessionId + "-" + Instant.now().toEpochMilli()
                : request.idempotencyKey().trim();

        Optional<RetailOrder> existing = retailOrderRepository.findByBusinessAndIdempotencyKeyForUpdate(
                session.getBusiness(), idempotencyKey);
        if (existing.isPresent()) {
            return replayGuestCheckout(existing.get(), paymentMethod);
        }

        String orderStatus = "CASH".equals(paymentMethod) ? "PAID" : "PENDING_PAYMENT";
        String paymentStatus = "CASH".equals(paymentMethod) ? "SUCCEEDED" : "PENDING";
        String orderNumber = "GUEST-" + UUID.randomUUID();
        RetailOrder order = new RetailOrder(
                session.getBusiness(),
                session.getBranch(),
                session,
                orderNumber,
                orderStatus,
                totalAmount,
                session.getBranch().getCurrency(),
                idempotencyKey,
                null);

        for (BasketItem item : basketItems) {
            Product product = item.getProduct();
            if (!product.isActive()) {
                throw new IllegalArgumentException("Product is not active: " + product.getName());
            }
            if (product.getStockQuantity() < item.getQuantity()) {
                throw new IllegalArgumentException("Insufficient stock for product: " + product.getName());
            }
            product.setStockQuantity(product.getStockQuantity() - item.getQuantity());
            BigDecimal taxAmount = item.getUnitPrice()
                    .multiply(product.getTaxRate())
                    .multiply(BigDecimal.valueOf(item.getQuantity()))
                    .setScale(2, java.math.RoundingMode.HALF_UP);
            order.getItems().add(new OrderItem(
                    order,
                    product,
                    item.getQuantity(),
                    item.getUnitPrice(),
                    taxAmount,
                    item.getLineTotal()));
        }

        order = retailOrderRepository.save(order);
        PaymentAttempt paymentAttempt = paymentAttemptRepository.save(new PaymentAttempt(
                order,
                paymentMethod,
                orderNumber,
                totalAmount,
                session.getBranch().getCurrency(),
                paymentStatus,
                idempotencyKey,
                request.cashReceived()));

        for (BasketItem item : basketItems) {
            inventoryMovementRepository.save(new InventoryMovement(
                    session.getBusiness(),
                    session.getBranch(),
                    item.getProduct(),
                    null,
                    order,
                    "SALE",
                    -item.getQuantity(),
                    "Guest checkout " + orderNumber));
        }

        session.setStatus("CHECKED_OUT");
        session.setUpdatedAt(Instant.now());
        sessionRepository.save(session);

        BigDecimal changeDue = BigDecimal.ZERO;
        if ("CASH".equals(paymentMethod) && request.cashReceived() != null) {
            changeDue = request.cashReceived().subtract(totalAmount).setScale(2, java.math.RoundingMode.HALF_UP);
            if (changeDue.signum() < 0) {
                throw new IllegalArgumentException("Cash received is less than the amount due");
            }
        }

        String exitTokenCode = null;
        if ("SUCCEEDED".equals(paymentAttempt.getStatus())) {
            exitTokenCode = issueGuestExitToken(order);
        }

        auditLogService.record(session.getBusiness(), null, "GUEST_CHECKOUT_COMPLETED", "RetailOrder",
                order.getId().toString(), orderNumber + "|" + totalAmount);

        return new GuestCheckoutResponse(
                session.getId().toString(),
                order.getId().toString(),
                orderNumber,
                orderStatus,
                paymentAttempt.getStatus(),
                totalAmount,
                session.getBranch().getCurrency(),
                orderNumber,
                exitTokenCode,
                changeDue);
    }

    @Transactional(readOnly = true)
    public GuestReceiptResponse getGuestReceipt(UUID sessionId, String accessToken) {
        ShoppingSession session = getGuestSession(sessionId, accessToken);
        RetailOrder order = retailOrderRepository.findTopBySessionOrderByCreatedAtDesc(session)
                .orElseThrow(() -> new IllegalArgumentException("No completed order found for this session"));
        List<BasketLine> lines = order.getItems().stream()
                .map(item -> new BasketLine(
                        item.getId().toString(),
                        item.getProduct().getId().toString(),
                        item.getProduct().getSku(),
                        item.getProduct().getName(),
                        item.getQuantity(),
                        item.getUnitPrice(),
                        item.getLineTotal()))
                .toList();
        String exitTokenCode = exitTokenRepository.findByOrder(order)
                .filter(token -> "ACTIVE".equals(token.getStatus()))
                .map(ExitToken::getTokenValue)
                .orElse(null);
        return new GuestReceiptResponse(
                order.getOrderNumber(),
                order.getId().toString(),
                session.getBranch().getName(),
                "Guest Shopper",
                order.getCreatedAt().toString(),
                order.getTotalAmount(),
                lines,
                exitTokenCode);
    }

    @Transactional
    public ExitVerificationResponse verifyGuestExitToken(String tokenCode) {
        if (tokenCode == null || tokenCode.isBlank()) {
            throw new IllegalArgumentException("Exit token is required");
        }
        String tokenHash = invitationTokenCodec.hash(tokenCode.trim());
        ExitToken exitToken = exitTokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new IllegalArgumentException("Exit token is invalid"));
        if (exitToken.getExpiresAt().isBefore(Instant.now())) {
            exitToken.setStatus("EXPIRED");
            exitTokenRepository.save(exitToken);
            throw new IllegalArgumentException("Exit token has expired");
        }
        if (!"ACTIVE".equals(exitToken.getStatus())) {
            throw new IllegalArgumentException("Exit token has already been redeemed");
        }
        RetailOrder order = exitToken.getOrder();
        if (!"PAID".equals(order.getStatus())) {
            throw new IllegalArgumentException("Order is not paid and cannot exit");
        }
        exitToken.setStatus("REDEEMED");
        exitTokenRepository.save(exitToken);
        return new ExitVerificationResponse(
                tokenCode,
                order.getId().toString(),
                "VERIFIED",
                exitToken.getExpiresAt());
    }

    private String issueGuestExitToken(RetailOrder order) {
        String token = invitationTokenCodec.issueToken();
        String tokenHash = invitationTokenCodec.hash(token);
        ExitToken exitToken = exitTokenRepository.findByOrder(order)
                .orElseGet(() -> new ExitToken(order, tokenHash, token, Instant.now().plus(Duration.ofHours(2))));
        if (exitToken.getTokenHash() == null || exitToken.getTokenHash().isBlank()) {
            exitToken = new ExitToken(order, tokenHash, token, Instant.now().plus(Duration.ofHours(2)));
        }
        if (exitToken.getTokenValue() == null || exitToken.getTokenValue().isBlank()) {
            exitToken = new ExitToken(order, tokenHash, token, Instant.now().plus(Duration.ofHours(2)));
        }
        exitTokenRepository.save(exitToken);
        return token;
    }

    private GuestCheckoutResponse replayGuestCheckout(RetailOrder order, String paymentMethod) {
        PaymentAttempt paymentAttempt = paymentAttemptRepository.findByOrderAndIdempotencyKey(
                order, order.getIdempotencyKey()).orElse(new PaymentAttempt(order, paymentMethod,
                order.getOrderNumber(), order.getTotalAmount(), order.getCurrency(),
                "SUCCEEDED", order.getIdempotencyKey(), order.getTotalAmount()));
        String exitTokenCode = exitTokenRepository.findByOrder(order)
                .filter(token -> "ACTIVE".equals(token.getStatus()))
                .map(ExitToken::getTokenValue)
                .orElse(null);
        String sessionIdValue = order.getSession() == null ? "" : order.getSession().getId().toString();
        return new GuestCheckoutResponse(
                sessionIdValue,
                order.getId().toString(),
                order.getOrderNumber(),
                order.getStatus(),
                paymentAttempt.getStatus(),
                order.getTotalAmount(),
                order.getCurrency(),
                order.getOrderNumber(),
                exitTokenCode,
                BigDecimal.ZERO);
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

    private String normalizePaymentMethod(String rawMethod) {
        if (rawMethod == null || rawMethod.isBlank()) {
            return "CASH";
        }
        String normalized = rawMethod.trim().toUpperCase();
        if ("MPESA".equals(normalized) || "M-PESA".equals(normalized) || "M_PESA".equals(normalized)) {
            return "M-PESA";
        }
        if ("CARD".equals(normalized) || "CREDIT_CARD".equals(normalized) || "DEBIT_CARD".equals(normalized)) {
            return "CARD";
        }
        return "CASH".equals(normalized) ? "CASH" : "CASH";
    }

    public record CreateSessionRequest(String sessionType, String branchName) {}
    public record AddBasketItemRequest(String productIdentifier, Integer quantity) {}
    public record GuestSessionResponse(String sessionId, String accessToken, String branchId, String branchName,
                                       String currency, boolean guestCheckoutEnabled, Instant expiresAt) {}
    public record GuestCheckoutRequest(String paymentMethod, BigDecimal cashReceived,
                                       String customerName, String phoneNumber, String idempotencyKey) {}
    public record GuestCheckoutResponse(String sessionId, String orderId, String orderNumber, String orderStatus,
                                       String paymentStatus, BigDecimal totalAmount, String currency,
                                       String receiptNumber, String exitTokenCode, BigDecimal changeDue) {}
    public record ExitVerificationResponse(String tokenCode, String orderId, String status, Instant expiresAt) {}
    public record GuestReceiptResponse(String receiptNumber, String orderId, String branchName,
                                      String customerName, String issueTimestamp, BigDecimal totalPaid,
                                      List<BasketLine> items, String exitTokenCode) {}
    public record BasketLine(String id, String productId, String productSku, String productName,
                             Integer quantity, BigDecimal unitPrice, BigDecimal lineTotal) {}
    public record BasketResponse(String sessionId, List<BasketLine> items, BigDecimal totalAmount) {}
}