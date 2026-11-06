package com.trixx.scanflow.service;

import com.trixx.scanflow.domain.Branch;
import com.trixx.scanflow.domain.ShoppingSession;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.domain.UserRole;
import com.trixx.scanflow.repository.UserBranchAccessRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

@Service
public class BranchAccessService {
    private final UserBranchAccessRepository userBranchAccessRepository;

    public BranchAccessService(UserBranchAccessRepository userBranchAccessRepository) {
        this.userBranchAccessRepository = userBranchAccessRepository;
    }

    public void requireBranchAccess(User user, Branch branch) {
        if (user.getBusiness() == null || !user.getBusiness().getId().equals(branch.getBusiness().getId())) {
            throw new AccessDeniedException("Branch access denied");
        }
        if (user.getRole() == UserRole.OWNER || user.getRole() == UserRole.BUSINESS_ADMIN || user.getRole() == UserRole.CUSTOMER) {
            return;
        }
        if (!userBranchAccessRepository.existsByUserAndBranch(user, branch)) {
            throw new AccessDeniedException("Branch access denied");
        }
    }

    public void requireSessionAccess(User user, ShoppingSession session) {
        if (user.getBusiness() == null || !user.getBusiness().getId().equals(session.getBusiness().getId())) {
            throw new AccessDeniedException("Shopping session access denied");
        }
        if (user.getRole() == UserRole.CUSTOMER) {
            if (session.getUser() == null || !session.getUser().getId().equals(user.getId())) {
                throw new AccessDeniedException("Shopping session access denied");
            }
            return;
        }
        requireBranchAccess(user, session.getBranch());
    }
}
