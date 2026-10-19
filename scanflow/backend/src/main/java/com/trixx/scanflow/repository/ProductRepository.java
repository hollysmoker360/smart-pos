package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface ProductRepository extends JpaRepository<Product, UUID> {
    Optional<Product> findByBusinessAndSku(Business business, String sku);
    Optional<Product> findByBusinessAndBarcode(Business business, String barcode);
    Page<Product> findByBusiness(Business business, Pageable pageable);
}
