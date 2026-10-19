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
        Optional<Product> bySku = productRepository.findByBusinessAndSku(business, request.sku());
        if (bySku.isPresent()) {
            throw new IllegalArgumentException("A product with this SKU already exists");
        }

        Product product = new Product(
                business,
                request.sku(),
                request.name(),
                request.barcode(),
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

    public Page<Product> findProducts(Business business, Pageable pageable) {
        return productRepository.findByBusiness(business, pageable);
    }

    public Product findByBusinessAndIdentifier(Business business, String identifier) {
        return productRepository.findByBusinessAndSku(business, identifier)
                .orElseGet(() -> productRepository.findByBusinessAndBarcode(business, identifier)
                        .orElseThrow(() -> new IllegalArgumentException("Product not found for identifier: " + identifier)));
    }

    public record CreateProductRequest(String sku, String name, String description, String brand, String barcode,
                                      BigDecimal price, BigDecimal taxRate, Integer stock, String category) {}
}
