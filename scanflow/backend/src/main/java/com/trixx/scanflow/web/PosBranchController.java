package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.Branch;
import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.repository.BranchRepository;
import com.trixx.scanflow.repository.UserBranchAccessRepository;
import com.trixx.scanflow.security.CustomUserPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/pos")
public class PosBranchController {
    private final BranchRepository branchRepository;
    private final UserBranchAccessRepository branchAccessRepository;

    public PosBranchController(BranchRepository branchRepository,
                               UserBranchAccessRepository branchAccessRepository) {
        this.branchRepository = branchRepository;
        this.branchAccessRepository = branchAccessRepository;
    }

    @GetMapping("/branches")
    @PreAuthorize("hasAnyRole('OWNER', 'BUSINESS_ADMIN', 'BRANCH_MANAGER', 'CASHIER')")
    public ResponseEntity<List<PosBranchResponse>> listAuthorizedBranches(
            @AuthenticationPrincipal CustomUserPrincipal principal) {
        Business business = principal.getUser().getBusiness();
        if (business == null) {
            throw new IllegalArgumentException("Business account required");
        }
        List<Branch> branches = switch (principal.getUser().getRole()) {
            case OWNER, BUSINESS_ADMIN -> branchRepository.findByBusiness(business).stream()
                    .filter(Branch::isActive)
                    .toList();
            default -> branchAccessRepository.findActiveBranchesByUser(principal.getUser()).stream()
                    .filter(branch -> branch.getBusiness().getId().equals(business.getId()))
                    .toList();
        };
        return ResponseEntity.ok(branches.stream().map(PosBranchResponse::from).toList());
    }

    public record PosBranchResponse(String id, String name, String currency, String timezone, boolean active) {
        static PosBranchResponse from(Branch branch) {
            return new PosBranchResponse(
                    branch.getId().toString(), branch.getName(), branch.getCurrency(),
                    branch.getTimezone(), branch.isActive());
        }
    }
}
