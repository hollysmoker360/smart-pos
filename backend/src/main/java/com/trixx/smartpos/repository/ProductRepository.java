package com.trixx.smartpos.repository;

import com.trixx.smartpos.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductRepository extends JpaRepository<Product, UUID> {
    List<Product> findByTenantId(UUID tenantId);
    Optional<Product> findByTenantIdAndSku(UUID tenantId, String sku);
}
