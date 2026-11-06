package com.trixx.scanflow.service;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.Product;
import com.trixx.scanflow.repository.ProductRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Optional;

@Service
public class ProductCatalogService {
    private final ProductRepository productRepository;

    public ProductCatalogService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Transactional
    public Product createProduct(Business business, CreateProductRequest request) {
        String sku = normalizeRequired(request.sku(), "SKU");
        String name = normalizeRequired(request.name(), "Product name");
        String barcode = normalizeOptional(request.barcode());

        if (request.price() != null && request.price().signum() < 0) {
            throw new IllegalArgumentException("Product price cannot be negative");
        }
        if (request.taxRate() != null && request.taxRate().signum() < 0) {
            throw new IllegalArgumentException("Tax rate cannot be negative");
        }
        if (request.stock() != null && request.stock() < 0) {
            throw new IllegalArgumentException("Stock quantity cannot be negative");
        }

        if (productRepository.findByBusinessAndSkuIgnoreCase(business, sku).isPresent()) {
            throw new IllegalArgumentException("A product with this SKU already exists");
        }
        if (!barcode.isBlank() && productRepository.findByBusinessAndBarcodeIgnoreCase(business, barcode).isPresent()) {
            throw new IllegalArgumentException("A product with this barcode already exists");
        }

        Product product = new Product(
                business,
                sku,
                name,
                barcode,
                request.price() == null ? BigDecimal.ZERO : request.price(),
                request.taxRate() == null ? BigDecimal.ZERO : request.taxRate(),
                request.stock() == null ? 0 : request.stock(),
                request.category()
        );
        product.setDescription(request.description());
        product.setBrand(request.brand());
        product.setActive(true);
        return productRepository.save(product);
    }

    private String normalizeRequired(String value, String fieldName) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(fieldName + " is required");
        }
        return value.trim();
    }

    private String normalizeOptional(String value) {
        return value == null ? "" : value.trim();
    }

    public Page<Product> findProducts(Business business, Pageable pageable) {
        return productRepository.findByBusiness(business, pageable);
    }

    public Product findByBusinessAndIdentifier(Business business, String identifier) {
        return productRepository.findByBusinessAndSku(business, identifier)
                .orElseGet(() -> productRepository.findByBusinessAndBarcode(business, identifier)
                        .orElseThrow(() -> new IllegalArgumentException("Product not found for identifier: " + identifier)));
    }

    public Product findByBusinessAndIdentifierForUpdate(Business business, String identifier) {
        return productRepository.findByBusinessAndSkuForUpdate(business, identifier)
                .orElseGet(() -> productRepository.findByBusinessAndBarcodeForUpdate(business, identifier)
                        .orElseThrow(() -> new IllegalArgumentException("Product not found for identifier: " + identifier)));
    }

    public record CreateProductRequest(String sku, String name, String description, String brand, String barcode,
                                      BigDecimal price, BigDecimal taxRate, Integer stock, String category) {}
}
