package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.Branch;
import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.security.CustomUserPrincipal;
import com.trixx.scanflow.repository.BranchRepository;
import com.trixx.scanflow.service.AuditLogService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Locale;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/businesses/me/branches")
@PreAuthorize("hasAnyRole('OWNER', 'BUSINESS_ADMIN')")
public class BranchManagementController {
    private final BranchRepository branchRepository;
    private final AuditLogService auditLogService;

    public BranchManagementController(BranchRepository branchRepository, AuditLogService auditLogService) {
        this.branchRepository = branchRepository;
        this.auditLogService = auditLogService;
    }

    @GetMapping
    public ResponseEntity<List<BranchResponse>> listBranches(@AuthenticationPrincipal CustomUserPrincipal principal) {
        Business business = requireBusiness(principal);
        return ResponseEntity.ok(branchRepository.findByBusiness(business).stream().map(BranchResponse::from).toList());
    }

    @GetMapping("/{branchId}/settings")
    public ResponseEntity<BranchSettingsResponse> getBranchSettings(@AuthenticationPrincipal CustomUserPrincipal principal,
                                                                    @PathVariable UUID branchId) {
        Branch branch = requireBranch(principal, branchId);
        return ResponseEntity.ok(BranchSettingsResponse.from(branch));
    }

    @PatchMapping("/{branchId}/settings")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<BranchSettingsResponse> updateBranchSettings(@AuthenticationPrincipal CustomUserPrincipal principal,
                                                                      @PathVariable UUID branchId,
                                                                      @Valid @RequestBody BranchSettingsRequest request) {
        Branch branch = requireBranch(principal, branchId);
        if (!request.phoneScanningEnabled() && !request.smartTrolleyEnabled() && !request.manualBarcodeEntryEnabled() && !request.cashierPosEnabled()) {
            throw new IllegalArgumentException("At least one scanning method must remain enabled");
        }

        branch.setPhoneScanningEnabled(request.phoneScanningEnabled());
        branch.setSmartTrolleyEnabled(request.smartTrolleyEnabled());
        branch.setCashierPosEnabled(request.cashierPosEnabled());
        branch.setGuestCheckoutEnabled(request.guestCheckoutEnabled());
        branch.setManualBarcodeEntryEnabled(request.manualBarcodeEntryEnabled());
        branch.setRequireStaffExitVerification(request.requireStaffExitVerification());
        branch.setRequireCustomerSignIn(request.requireCustomerSignIn());
        branch = branchRepository.save(branch);

        auditLogService.record(principal.getUser().getBusiness(), principal.getUser(), "BRANCH_SETTINGS_UPDATED",
                "Branch", branch.getId().toString(), branch.getName());
        return ResponseEntity.ok(BranchSettingsResponse.from(branch));
    }

    @PostMapping
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<BranchResponse> createBranch(@AuthenticationPrincipal CustomUserPrincipal principal,
                                                       @Valid @RequestBody CreateBranchRequest request) {
        Business business = requireBusiness(principal);
        String name = request.name().trim();
        if (branchRepository.existsByBusinessAndName(business, name)) {
            throw new IllegalArgumentException("A branch with that name already exists");
        }
        Branch branch = new Branch(business, name);
        if (request.currency() != null && !request.currency().isBlank()) {
            branch.setCurrency(request.currency().trim().toUpperCase(Locale.ROOT));
        }
        if (request.timezone() != null && !request.timezone().isBlank()) {
            branch.setTimezone(request.timezone().trim());
        }
        branch = branchRepository.save(branch);
        auditLogService.record(business, principal.getUser(), "BRANCH_CREATED", "Branch", branch.getId().toString(), branch.getName());
        return ResponseEntity.status(HttpStatus.CREATED).body(BranchResponse.from(branch));
    }

    private Business requireBusiness(CustomUserPrincipal principal) {
        Business business = principal.getUser().getBusiness();
        if (business == null) {
            throw new IllegalArgumentException("Business account required");
        }
        return business;
    }

    private Branch requireBranch(CustomUserPrincipal principal, UUID branchId) {
        Business business = requireBusiness(principal);
        return branchRepository.findById(branchId)
                .filter(candidate -> candidate.getBusiness().getId().equals(business.getId()))
                .orElseThrow(() -> new IllegalArgumentException("Branch not found"));
    }

    public record CreateBranchRequest(@NotBlank @Size(max = 255) String name,
                                     @Size(min = 3, max = 3) String currency,
                                     @Size(max = 64) String timezone) {}
    public record BranchSettingsRequest(boolean phoneScanningEnabled, boolean smartTrolleyEnabled,
                                        boolean manualBarcodeEntryEnabled, boolean cashierPosEnabled,
                                        boolean guestCheckoutEnabled, boolean requireStaffExitVerification,
                                        boolean requireCustomerSignIn) {}
    public record BranchResponse(String id, String name, String currency, String timezone, boolean active,
                                boolean phoneScanningEnabled, boolean smartTrolleyEnabled,
                                boolean cashierPosEnabled, boolean guestCheckoutEnabled,
                                boolean manualBarcodeEntryEnabled, boolean requireStaffExitVerification,
                                boolean requireCustomerSignIn) {
        static BranchResponse from(Branch branch) {
            return new BranchResponse(branch.getId().toString(), branch.getName(), branch.getCurrency(), branch.getTimezone(),
                    branch.isActive(), branch.isPhoneScanningEnabled(), branch.isSmartTrolleyEnabled(),
                    branch.isCashierPosEnabled(), branch.isGuestCheckoutEnabled(), branch.isManualBarcodeEntryEnabled(),
                    branch.isRequireStaffExitVerification(), branch.isRequireCustomerSignIn());
        }
    }
    public record BranchSettingsResponse(boolean phoneScanningEnabled, boolean smartTrolleyEnabled,
                                        boolean cashierPosEnabled, boolean guestCheckoutEnabled,
                                        boolean manualBarcodeEntryEnabled, boolean requireStaffExitVerification,
                                        boolean requireCustomerSignIn) {
        static BranchSettingsResponse from(Branch branch) {
            return new BranchSettingsResponse(branch.isPhoneScanningEnabled(), branch.isSmartTrolleyEnabled(),
                    branch.isCashierPosEnabled(), branch.isGuestCheckoutEnabled(), branch.isManualBarcodeEntryEnabled(),
                    branch.isRequireStaffExitVerification(), branch.isRequireCustomerSignIn());
        }
    }
}
