package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.AuditEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AuditEventRepository extends JpaRepository<AuditEvent, Long> {
    List<AuditEvent> findByBranchIdOrderByCreatedAtDesc(Long branchId);
}
