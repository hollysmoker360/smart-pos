package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.Branch;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.domain.UserBranchAccess;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface UserBranchAccessRepository extends JpaRepository<UserBranchAccess, UUID> {
    boolean existsByUserAndBranch(User user, Branch branch);
    List<UserBranchAccess> findByUser(User user);
}
