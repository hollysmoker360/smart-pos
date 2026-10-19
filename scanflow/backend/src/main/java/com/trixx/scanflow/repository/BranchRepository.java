package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.Branch;
import com.trixx.scanflow.domain.Business;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface BranchRepository extends JpaRepository<Branch, UUID> {
    List<Branch> findByBusiness(Business business);
    Branch findByBusinessAndName(Business business, String name);
}
