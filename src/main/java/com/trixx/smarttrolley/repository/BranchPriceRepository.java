package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.BranchPrice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BranchPriceRepository extends JpaRepository<BranchPrice, Long> {
    @Query("SELECT bp FROM BranchPrice bp WHERE bp.branch.id = :branchId AND bp.product.id = :productId AND bp.status = 'ACTIVE' ORDER BY bp.effectiveFrom DESC")
    List<BranchPrice> findActivePrices(@Param("branchId") Long branchId, @Param("productId") Long productId);
}
