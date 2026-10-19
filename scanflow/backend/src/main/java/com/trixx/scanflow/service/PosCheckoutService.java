package com.trixx.scanflow.service;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.Product;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
public class PosCheckoutService {
    private final ProductCatalogService productCatalogService;

    public PosCheckoutService(ProductCatalogService productCatalogService) {
        this.productCatalogService = productCatalogService;
    }

    @Transactional
    public PosCheckoutResponse checkout(Business business, PosCheckoutRequest request) {
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

            product.setStockQuantity(product.getStockQuantity() - itemRequest.quantity());
        }

        return new PosCheckoutResponse(items, totalAmount.doubleValue(), request.items().size());
    }

    public record PosCheckoutRequest(List<PosCheckoutItemRequest> items) {}
    public record PosCheckoutItemRequest(String productId, Integer quantity) {}
    public record PosCheckoutItemResponse(String productId, String name, Integer quantity, BigDecimal unitPrice, BigDecimal lineTotal) {}
    public record PosCheckoutResponse(List<PosCheckoutItemResponse> items, double totalAmount, int itemCount) {}
}
