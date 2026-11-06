package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.UserRole;
import com.trixx.scanflow.security.CustomUserPrincipal;
import com.trixx.scanflow.service.EmployeeInvitationService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/businesses/me/employee-invitations")
@PreAuthorize("hasAnyRole('OWNER', 'BUSINESS_ADMIN')")
public class EmployeeInvitationController {
    private final EmployeeInvitationService invitationService;

    public EmployeeInvitationController(EmployeeInvitationService invitationService) {
        this.invitationService = invitationService;
    }

    @PostMapping
    public ResponseEntity<EmployeeInvitationService.CreatedEmployeeInvitation> createInvitation(
            @AuthenticationPrincipal CustomUserPrincipal principal,
            @Valid @RequestBody CreateEmployeeInvitationRequest request) {
        var invitation = invitationService.createInvitation(principal.getUser(),
                new EmployeeInvitationService.CreateEmployeeInvitationRequest(
                        request.fullName(), request.email(), request.phone(), request.role(), request.branchIds()));
        return ResponseEntity.status(HttpStatus.CREATED).body(invitation);
    }

    public record CreateEmployeeInvitationRequest(@NotBlank @Size(max = 255) String fullName,
                                                  @NotBlank @Email @Size(max = 255) String email,
                                                  @NotBlank @Size(max = 50) String phone,
                                                  UserRole role,
                                                  @NotEmpty List<UUID> branchIds) {}
}
