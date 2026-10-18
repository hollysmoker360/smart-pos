package com.trixx.smarttrolley.service;

import com.trixx.smarttrolley.domain.*;
import com.trixx.smarttrolley.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
public class CatalogueAndPricingService {

    private final ProductRepository productRepository;
    private final ProductBarcodeRepository barcodeRepository;
    private final BranchPriceRepository branchPriceRepository;

    public CatalogueAndPricingService(ProductRepository productRepository,
                                       ProductBarcodeRepository barcodeRepository,
                                       BranchPriceRepository branchPriceRepository) {
        this.productRepository = productRepository;
        this.barcodeRepository = barcodeRepository;
        this.branchPriceRepository = branchPriceRepository;
    }

    @Transactional(readOnly = true)
    public Product resolveProductByBarcode(String barcode) {
        ProductBarcode productBarcode = barcodeRepository.findByBarcode(barcode)
                .orElseThrow(() -> new IllegalArgumentException("BARCODE_UNKNOWN: Barcode " + barcode + " is not registered"));
        return productBarcode.getProduct();
    }

    @Transactional(readOnly = true)
    public BigDecimal getActiveBranchPrice(Long branchId, Long productId) {
        var prices = branchPriceRepository.findActivePrices(branchId, productId);
        if (prices.isEmpty()) {
            throw new IllegalStateException("PRICE_NOT_CONFIGURED: No active price found for branch " + branchId + " and product " + productId);
        }
        return prices.get(0).getSellingPrice();
    }
}
