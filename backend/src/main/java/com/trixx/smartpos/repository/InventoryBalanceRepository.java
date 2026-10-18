package com.trixx.smartpos.repository;

import com.trixx.smartpos.model.InventoryBalance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface InventoryBalanceRepository extends JpaRepository<InventoryBalance, UUID> {
    Optional<InventoryBalance> findByBranchIdAndProductId(UUID branchId, UUID productId);
    List<InventoryBalance> findByBranchId(UUID branchId);
}
