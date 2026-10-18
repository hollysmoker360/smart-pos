package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    Optional<Product> findByTenantIdAndSku(Long tenantId, String sku);
    List<Product> findByTenantId(Long tenantId);
}
