package com.trixx.smartpos.repository;

import com.trixx.smartpos.model.BranchPrice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface BranchPriceRepository extends JpaRepository<BranchPrice, UUID> {
    Optional<BranchPrice> findByBranchIdAndProductId(UUID branchId, UUID productId);
}
