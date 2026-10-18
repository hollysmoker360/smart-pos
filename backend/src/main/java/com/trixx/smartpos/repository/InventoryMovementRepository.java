package com.trixx.smartpos.repository;

import com.trixx.smartpos.model.InventoryMovement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface InventoryMovementRepository extends JpaRepository<InventoryMovement, UUID> {
    List<InventoryMovement> findByBranchIdAndProductId(UUID branchId, UUID productId);
    List<InventoryMovement> findByBranchId(UUID branchId);
}
