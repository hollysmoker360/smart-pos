package com.trixx.smartpos.repository;

import com.trixx.smartpos.model.ProductBarcode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductBarcodeRepository extends JpaRepository<ProductBarcode, UUID> {
    Optional<ProductBarcode> findByBarcode(String barcode);
    List<ProductBarcode> findByProductId(UUID productId);
}
