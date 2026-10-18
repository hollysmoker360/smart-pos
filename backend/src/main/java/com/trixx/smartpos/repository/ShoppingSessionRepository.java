package com.trixx.smartpos.repository;

import com.trixx.smartpos.model.ShoppingSession;
import com.trixx.smartpos.model.ShoppingSessionItem;
import com.trixx.smartpos.model.OutboxEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ShoppingSessionRepository extends JpaRepository<ShoppingSession, UUID> {
    Optional<ShoppingSession> findByIdAndTenantIdAndBranchId(UUID id, UUID tenantId, UUID branchId);
}
