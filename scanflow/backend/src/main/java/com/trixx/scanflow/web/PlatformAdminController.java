package com.trixx.scanflow.web;

import com.trixx.scanflow.security.CustomUserPrincipal;
import com.trixx.scanflow.service.BusinessInvitationService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/platform")
@PreAuthorize("hasRole('PLATFORM_ADMIN')")
public class PlatformAdminController {
    private final BusinessInvitationService invitationService;

    public PlatformAdminController(BusinessInvitationService invitationService) {
        this.invitationService = invitationService;
    }

    @PostMapping("/business-invitations")
    public ResponseEntity<BusinessInvitationService.CreatedInvitation> inviteBusinessOwner(
            @AuthenticationPrincipal CustomUserPrincipal principal,
            @Valid @RequestBody CreateBusinessInvitationRequest request) {
        var invitation = invitationService.createInvitation(principal.getUser(), new BusinessInvitationService.CreateInvitationRequest(
                request.businessName(), request.ownerName(), request.ownerEmail(), request.ownerPhone()));
        return ResponseEntity.status(HttpStatus.CREATED).body(invitation);
    }

    public record CreateBusinessInvitationRequest(@NotBlank @Size(max = 255) String businessName,
                                                 @NotBlank @Size(max = 255) String ownerName,
                                                 @NotBlank @Email @Size(max = 255) String ownerEmail,
                                                 @NotBlank @Size(max = 50) String ownerPhone) {}
}
