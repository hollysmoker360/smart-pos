package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.Product;
import com.trixx.scanflow.security.CustomUserPrincipal;
import com.trixx.scanflow.service.ProductCatalogService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("/api/v1")
public class ProductController {
    private final ProductCatalogService productCatalogService;

    public ProductController(ProductCatalogService productCatalogService) {
        this.productCatalogService = productCatalogService;
    }

    @PostMapping("/products")
    public ResponseEntity<ProductResponse> createProduct(@AuthenticationPrincipal CustomUserPrincipal principal,
                                                        @RequestBody ProductCatalogService.CreateProductRequest request) {
        Business business = principal.getUser().getBusiness();
        Product product = productCatalogService.createProduct(business, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(product));
    }

    @GetMapping("/products")
    public ResponseEntity<Page<ProductResponse>> listProducts(@AuthenticationPrincipal CustomUserPrincipal principal,
                                                             @RequestParam(defaultValue = "0") int page,
                                                             @RequestParam(defaultValue = "20") int size) {
        Business business = principal.getUser().getBusiness();
        Page<Product> products = productCatalogService.findProducts(business, PageRequest.of(page, size));
        return ResponseEntity.ok(products.map(this::toResponse));
    }

    private ProductResponse toResponse(Product product) {
        return new ProductResponse(
                product.getId().toString(),
                product.getSku(),
                product.getName(),
                product.getBarcode(),
                product.getStandardPrice(),
                product.getTaxRate(),
                product.getStockQuantity(),
                product.getCategory(),
                product.getDescription(),
                product.getBrand(),
                product.isActive()
        );
    }

    public record ProductResponse(String id, String sku, String name, String barcode, BigDecimal price,
                                 BigDecimal taxRate, Integer stock, String category, String description,
                                 String brand, boolean active) {}
}
