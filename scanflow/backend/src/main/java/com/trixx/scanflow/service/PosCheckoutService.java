package com.trixx.scanflow.service;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.Branch;
import com.trixx.scanflow.domain.Product;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.repository.BranchRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class PosCheckoutService {
    private final ProductCatalogService productCatalogService;
    private final BranchRepository branchRepository;
    private final BranchAccessService branchAccessService;

    public PosCheckoutService(ProductCatalogService productCatalogService, BranchRepository branchRepository,
                              BranchAccessService branchAccessService) {
        this.productCatalogService = productCatalogService;
        this.branchRepository = branchRepository;
        this.branchAccessService = branchAccessService;
    }

    @Transactional
    public PosCheckoutResponse checkout(Business business, User user, PosCheckoutRequest request) {
        if (request.branchId() == null) {
            throw new IllegalArgumentException("Branch is required");
        }
        Branch branch = branchRepository.findById(request.branchId())
                .filter(candidate -> candidate.getBusiness().getId().equals(business.getId()))
                .orElseThrow(() -> new IllegalArgumentException("Branch not found"));
        branchAccessService.requireBranchAccess(user, branch);
        if (request.items() == null || request.items().isEmpty()) {
            throw new IllegalArgumentException("At least one checkout item is required");
        }

        List<PosCheckoutItemResponse> items = new ArrayList<>();
        BigDecimal totalAmount = BigDecimal.ZERO;

        for (PosCheckoutItemRequest itemRequest : request.items()) {
            Product product = productCatalogService.findByBusinessAndIdentifier(business, itemRequest.productId());
            if (itemRequest.quantity() == null || itemRequest.quantity() <= 0) {
                throw new IllegalArgumentException("Quantity must be greater than zero");
            }
            if (product.getStockQuantity() < itemRequest.quantity()) {
                throw new IllegalArgumentException("Insufficient stock for product: " + product.getName());
            }

            BigDecimal lineTotal = product.getStandardPrice().multiply(BigDecimal.valueOf(itemRequest.quantity()));
            totalAmount = totalAmount.add(lineTotal);
            items.add(new PosCheckoutItemResponse(product.getSku(), product.getName(), itemRequest.quantity(), product.getStandardPrice(), lineTotal));

        }

        return new PosCheckoutResponse(items, totalAmount.doubleValue(), request.items().size());
    }

    public record PosCheckoutRequest(UUID branchId, List<PosCheckoutItemRequest> items) {}
    public record PosCheckoutItemRequest(String productId, Integer quantity) {}
    public record PosCheckoutItemResponse(String productId, String name, Integer quantity, BigDecimal unitPrice, BigDecimal lineTotal) {}
    public record PosCheckoutResponse(List<PosCheckoutItemResponse> items, double totalAmount, int itemCount) {}
}
