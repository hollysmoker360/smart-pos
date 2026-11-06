package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.Product;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ProductRepository extends JpaRepository<Product, UUID> {
    Optional<Product> findByBusinessAndSku(Business business, String sku);
    Optional<Product> findByBusinessAndBarcode(Business business, String barcode);
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select product from Product product where product.business = :business and product.sku = :identifier")
    Optional<Product> findByBusinessAndSkuForUpdate(@Param("business") Business business,
                                                    @Param("identifier") String identifier);
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select product from Product product where product.business = :business and product.barcode = :identifier")
    Optional<Product> findByBusinessAndBarcodeForUpdate(@Param("business") Business business,
                                                        @Param("identifier") String identifier);
    Page<Product> findByBusiness(Business business, Pageable pageable);
}
