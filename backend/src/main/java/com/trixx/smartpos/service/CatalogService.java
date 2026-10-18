package com.trixx.smartpos.service;

import com.trixx.smartpos.model.*;
import com.trixx.smartpos.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class CatalogService {

    private final TenantRepository tenantRepository;
    private final BranchRepository branchRepository;
    private final ProductRepository productRepository;
    private final ProductBarcodeRepository productBarcodeRepository;
    private final BranchPriceRepository branchPriceRepository;
    private final InventoryBalanceRepository inventoryBalanceRepository;
    private final InventoryMovementRepository inventoryMovementRepository;

    public CatalogService(
            TenantRepository tenantRepository,
            BranchRepository branchRepository,
            ProductRepository productRepository,
            ProductBarcodeRepository productBarcodeRepository,
            BranchPriceRepository branchPriceRepository,
            InventoryBalanceRepository inventoryBalanceRepository,
            InventoryMovementRepository inventoryMovementRepository) {
        this.tenantRepository = tenantRepository;
        this.branchRepository = branchRepository;
        this.productRepository = productRepository;
        this.productBarcodeRepository = productBarcodeRepository;
        this.branchPriceRepository = branchPriceRepository;
        this.inventoryBalanceRepository = inventoryBalanceRepository;
        this.inventoryMovementRepository = inventoryMovementRepository;
    }

    public List<Branch> getAllBranches() {
        return branchRepository.findAll();
    }

    public Optional<Branch> getBranchById(UUID branchId) {
        return branchRepository.findById(branchId);
    }

    public Optional<Product> resolveProductByBarcode(String barcode) {
        return productBarcodeRepository.findByBarcode(barcode)
                .flatMap(pb -> productRepository.findById(pb.getProductId()));
    }

    public BigDecimal getEffectivePrice(UUID branchId, UUID productId) {
        return branchPriceRepository.findByBranchIdAndProductId(branchId, productId)
                .map(BranchPrice::getPrice)
                .orElse(BigDecimal.ZERO);
    }

    @Transactional
    public void recordInventoryMovement(UUID tenantId, UUID branchId, UUID productId, String type, BigDecimal quantity, String ref, String reason, UUID userId) {
        InventoryMovement movement = InventoryMovement.builder()
                .tenantId(tenantId)
                .branchId(branchId)
                .productId(productId)
                .movementType(type)
                .quantity(quantity)
                .referenceId(ref)
                .reason(reason)
                .createdBy(userId)
                .createdAt(Instant.now())
                .build();
        inventoryMovementRepository.save(movement);

        InventoryBalance balance = inventoryBalanceRepository.findByBranchIdAndProductId(branchId, productId)
                .orElseGet(() -> InventoryBalance.builder()
                        .branchId(branchId)
                        .productId(productId)
                        .availableQuantity(BigDecimal.ZERO)
                        .reservedQuantity(BigDecimal.ZERO)
                        .damagedQuantity(BigDecimal.ZERO)
                        .build());

        if ("SALE".equalsIgnoreCase(type)) {
            balance.setAvailableQuantity(balance.getAvailableQuantity().subtract(quantity));
        } else if ("RECEIPT".equalsIgnoreCase(type) || "RESTOCK".equalsIgnoreCase(type)) {
            balance.setAvailableQuantity(balance.getAvailableQuantity().add(quantity));
        } else if ("DAMAGE".equalsIgnoreCase(type)) {
            balance.setAvailableQuantity(balance.getAvailableQuantity().subtract(quantity));
            balance.setDamagedQuantity(balance.getDamagedQuantity().add(quantity));
        }
        balance.setUpdatedAt(Instant.now());
        inventoryBalanceRepository.save(balance);
    }
}
