package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.ProductBarcode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ProductBarcodeRepository extends JpaRepository<ProductBarcode, Long> {
    Optional<ProductBarcode> findByBarcode(String barcode);
}
