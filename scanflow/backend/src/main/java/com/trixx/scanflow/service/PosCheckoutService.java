package com.trixx.scanflow.service;

import com.trixx.scanflow.domain.*;
import com.trixx.scanflow.repository.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.*;

@Service
public class PosCheckoutService {
    private final ProductCatalogService productCatalogService;
    private final BranchRepository branchRepository;
    private final BranchAccessService branchAccessService;
    private final RetailOrderRepository orderRepository;
    private final PaymentAttemptRepository paymentAttemptRepository;
    private final InventoryMovementRepository inventoryMovementRepository;
    private final AuditLogService auditLogService;

    public PosCheckoutService(ProductCatalogService productCatalogService, BranchRepository branchRepository,
                              BranchAccessService branchAccessService, RetailOrderRepository orderRepository,
                              PaymentAttemptRepository paymentAttemptRepository,
                              InventoryMovementRepository inventoryMovementRepository,
                              AuditLogService auditLogService) {
        this.productCatalogService = productCatalogService;
        this.branchRepository = branchRepository;
        this.branchAccessService = branchAccessService;
        this.orderRepository = orderRepository;
        this.paymentAttemptRepository = paymentAttemptRepository;
        this.inventoryMovementRepository = inventoryMovementRepository;
        this.auditLogService = auditLogService;
    }

    @Transactional(readOnly = true)
    public PosQuoteResponse quote(Business business, User user, PosQuoteRequest request) {
        Branch branch = requireAccessibleBranch(business, user, request.branchId());
        List<PreparedLine> lines = prepareLines(business, request.items(), false, true);
        return quoteResponse(branch, lines);
    }

    @Transactional
    public PosCheckoutResponse checkout(Business business, User user, PosCheckoutRequest request) {
        if (request.idempotencyKey() == null || request.idempotencyKey().isBlank()) {
            throw new IllegalArgumentException("An idempotency key is required");
        }
        if (!"CASH".equals(request.paymentMethod())) {
            throw new IllegalArgumentException("Only cash payment is currently available at the POS");
        }
        if (request.cashReceived() == null || request.cashReceived().signum() < 0) {
            throw new IllegalArgumentException("Cash received must be zero or greater");
        }

        Branch branch = requireAccessibleBranch(business, user, request.branchId());
        List<PreparedLine> requestedLines = prepareLines(business, request.items(), false, false);
        String fingerprint = fingerprint(branch, requestedLines, request.paymentMethod(), request.cashReceived());
        Optional<RetailOrder> existing = orderRepository.findByBusinessAndIdempotencyKeyForUpdate(
                business, request.idempotencyKey().trim());
        if (existing.isPresent()) {
            return replay(existing.get(), fingerprint);
        }

        List<PreparedLine> lines = prepareLines(business, request.items(), true, true);
        existing = orderRepository.findByBusinessAndIdempotencyKeyForUpdate(
                business, request.idempotencyKey().trim());
        if (existing.isPresent()) {
            return replay(existing.get(), fingerprint);
        }
        PosQuoteResponse quote = quoteResponse(branch, lines);
        if (request.cashReceived().compareTo(quote.totalAmount()) < 0) {
            throw new IllegalArgumentException("Cash received is less than the amount due");
        }

        String orderNumber = "POS-" + UUID.randomUUID();
        RetailOrder order = new RetailOrder(business, branch, orderNumber, "PAID",
                quote.totalAmount(), branch.getCurrency(), request.idempotencyKey().trim(), fingerprint);
        for (PreparedLine line : lines) {
            Product product = line.product();
            product.setStockQuantity(product.getStockQuantity() - line.quantity());
            order.getItems().add(new OrderItem(order, product, line.quantity(), product.getStandardPrice(),
                    line.taxAmount(), line.lineTotal()));
        }
        order = orderRepository.save(order);

        paymentAttemptRepository.save(new PaymentAttempt(order, "CASH", orderNumber, quote.totalAmount(),
                branch.getCurrency(), "SUCCEEDED", request.idempotencyKey().trim(), request.cashReceived()));
        for (PreparedLine line : lines) {
            inventoryMovementRepository.save(new InventoryMovement(business, branch, line.product(), user, order,
                    "SALE", -line.quantity(), "POS sale " + orderNumber));
        }
        auditLogService.record(business, user, "POS_CHECKOUT_COMPLETED", "Order",
                order.getId().toString(), orderNumber + "|" + quote.totalAmount());
        return checkoutResponse(order, request.cashReceived());
    }

    private Branch requireAccessibleBranch(Business business, User user, UUID branchId) {
        if (branchId == null) {
            throw new IllegalArgumentException("Branch is required");
        }
        Branch branch = branchRepository.findById(branchId)
                .filter(candidate -> candidate.getBusiness().getId().equals(business.getId()))
                .filter(Branch::isActive)
                .orElseThrow(() -> new IllegalArgumentException("Active branch not found"));
        branchAccessService.requireBranchAccess(user, branch);
        return branch;
    }

    private List<PreparedLine> prepareLines(Business business, List<PosCheckoutItemRequest> requests,
                                            boolean lockProducts, boolean checkStock) {
        if (requests == null || requests.isEmpty()) {
            throw new IllegalArgumentException("At least one checkout item is required");
        }
        Map<UUID, PreparedLine> lines = new HashMap<>();
        for (PosCheckoutItemRequest request : requests) {
            if (request.productId() == null || request.productId().isBlank()) {
                throw new IllegalArgumentException("Product identifier is required");
            }
            if (request.quantity() == null || request.quantity() <= 0) {
                throw new IllegalArgumentException("Quantity must be greater than zero");
            }
            Product product = lockProducts
                    ? productCatalogService.findByBusinessAndIdentifierForUpdate(business, request.productId().trim())
                    : productCatalogService.findByBusinessAndIdentifier(business, request.productId().trim());
            if (!product.isActive()) {
                throw new IllegalArgumentException("Product is not active: " + product.getName());
            }
            PreparedLine previous = lines.get(product.getId());
            int quantity = Math.addExact(previous == null ? 0 : previous.quantity(), request.quantity());
            if (checkStock && product.getStockQuantity() < quantity) {
                throw new IllegalArgumentException("Insufficient stock for product: " + product.getName());
            }
            BigDecimal subtotal = product.getStandardPrice()
                    .multiply(BigDecimal.valueOf(quantity))
                    .setScale(2, RoundingMode.HALF_UP);
            BigDecimal tax = subtotal.multiply(product.getTaxRate()).setScale(2, RoundingMode.HALF_UP);
            lines.put(product.getId(), new PreparedLine(product, quantity, tax, subtotal.add(tax)));
        }
        return lines.values().stream().sorted(Comparator.comparing(line -> line.product().getId())).toList();
    }

    private PosQuoteResponse quoteResponse(Branch branch, List<PreparedLine> lines) {
        BigDecimal subtotal = lines.stream()
                .map(line -> line.product().getStandardPrice().multiply(BigDecimal.valueOf(line.quantity()))
                        .setScale(2, RoundingMode.HALF_UP))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal tax = lines.stream().map(PreparedLine::taxAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal total = subtotal.add(tax);
        int itemCount = lines.stream().mapToInt(PreparedLine::quantity).sum();
        List<PosQuoteItemResponse> items = lines.stream().map(line -> new PosQuoteItemResponse(
                line.product().getId().toString(), line.product().getSku(), line.product().getName(),
                line.quantity(), line.product().getStandardPrice(), line.taxAmount(), line.lineTotal())).toList();
        return new PosQuoteResponse(branch.getId().toString(), branch.getCurrency(), items, subtotal, tax, total, itemCount);
    }

    private String fingerprint(Branch branch, List<PreparedLine> lines, String paymentMethod, BigDecimal cashReceived) {
        String canonicalLines = lines.stream()
                .map(line -> line.product().getId() + ":" + line.quantity())
                .sorted()
                .reduce("", (left, right) -> left + "|" + right);
        String content = branch.getId() + "|" + paymentMethod + "|"
                + cashReceived.stripTrailingZeros().toPlainString() + canonicalLines;
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(content.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is not available", exception);
        }
    }

    private PosCheckoutResponse replay(RetailOrder order, String fingerprint) {
        if (!order.getRequestFingerprint().equals(fingerprint)) {
            throw new IllegalArgumentException("Idempotency key was already used for a different checkout");
        }
        PaymentAttempt payment = paymentAttemptRepository.findByOrderAndIdempotencyKey(
                        order, order.getIdempotencyKey())
                .orElseThrow(() -> new IllegalStateException("Checkout payment record is missing"));
        return checkoutResponse(order, payment.getCashReceived());
    }

    private PosCheckoutResponse checkoutResponse(RetailOrder order, BigDecimal cashReceived) {
        List<PosCheckoutItemResponse> items = order.getItems().stream().map(item -> new PosCheckoutItemResponse(
                item.getProduct().getId().toString(), item.getProduct().getSku(), item.getProduct().getName(),
                item.getQuantity(), item.getUnitPrice(), item.getTaxAmount(), item.getLineTotal())).toList();
        int itemCount = items.stream().mapToInt(PosCheckoutItemResponse::quantity).sum();
        return new PosCheckoutResponse(order.getId().toString(), order.getOrderNumber(), order.getStatus(),
                "SUCCEEDED", "CASH", order.getCurrency(), items, order.getTotalAmount(), itemCount,
                cashReceived, cashReceived.subtract(order.getTotalAmount()));
    }

    public record PosQuoteRequest(@NotNull UUID branchId,
                                  @NotEmpty List<@NotNull PosCheckoutItemRequest> items) {}
    public record PosCheckoutRequest(@NotNull UUID branchId,
                                     @NotEmpty List<@NotNull PosCheckoutItemRequest> items,
                                     @NotBlank @Size(max = 255) String idempotencyKey,
                                     @NotBlank String paymentMethod,
                                     @NotNull @DecimalMin("0.00") BigDecimal cashReceived) {}
    public record PosCheckoutItemRequest(@NotBlank @Size(max = 255) String productId,
                                         @NotNull @Min(1) Integer quantity) {}
    public record PosQuoteItemResponse(String productId, String sku, String name, Integer quantity,
                                       BigDecimal unitPrice, BigDecimal taxAmount, BigDecimal lineTotal) {}
    public record PosQuoteResponse(String branchId, String currency, List<PosQuoteItemResponse> items,
                                   BigDecimal subtotalAmount, BigDecimal taxAmount, BigDecimal totalAmount,
                                   int itemCount) {}
    public record PosCheckoutItemResponse(String productId, String sku, String name, Integer quantity,
                                          BigDecimal unitPrice, BigDecimal taxAmount, BigDecimal lineTotal) {}
    public record PosCheckoutResponse(String orderId, String orderNumber, String orderStatus, String paymentStatus,
                                      String paymentMethod, String currency, List<PosCheckoutItemResponse> items,
                                      BigDecimal totalAmount, int itemCount, BigDecimal cashReceived,
                                      BigDecimal changeDue) {}
    private record PreparedLine(Product product, int quantity, BigDecimal taxAmount, BigDecimal lineTotal) {}
}
