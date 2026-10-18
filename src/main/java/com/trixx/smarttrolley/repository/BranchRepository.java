package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.Branch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BranchRepository extends JpaRepository<Branch, Long> {
    List<Branch> findByTenantId(Long tenantId);
    Optional<Branch> findByTenantIdAndCode(Long tenantId, String code);
}
