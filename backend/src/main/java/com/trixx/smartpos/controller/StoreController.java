package com.trixx.smartpos.controller;

import com.trixx.smartpos.model.Branch;
import com.trixx.smartpos.model.Product;
import com.trixx.smartpos.service.CatalogService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping("/api/v1/stores")
public class StoreController {

    private final CatalogService catalogService;

    public StoreController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping
    public ResponseEntity<List<Branch>> getBranches() {
        return ResponseEntity.ok(catalogService.getAllBranches());
    }

    @GetMapping("/{storeId}/products/{barcode}")
    public ResponseEntity<Map<String, Object>> resolveBarcode(
            @PathVariable UUID storeId,
            @PathVariable String barcode) {

        Product product = catalogService.resolveProductByBarcode(barcode)
                .orElseThrow(() -> new IllegalArgumentException("Product barcode not found: " + barcode));

        BigDecimal price = catalogService.getEffectivePrice(storeId, product.getId());

        Map<String, Object> response = new HashMap<>();
        response.put("productId", product.getId());
        response.put("name", product.getName());
        response.put("sku", product.getSku());
        response.put("category", product.getCategory());
        response.put("brand", product.getBrand());
        response.put("packageSize", product.getPackageSize());
        response.put("taxRate", product.getTaxRate());
        response.put("unitPrice", price);
        response.put("barcode", barcode);

        return ResponseEntity.ok(response);
    }
}
