package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.security.CustomUserPrincipal;
import com.trixx.scanflow.security.JwtService;
import com.trixx.scanflow.service.BusinessInvitationService;
import com.trixx.scanflow.service.BusinessRegistrationService;
import com.trixx.scanflow.service.EmployeeInvitationService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.Locale;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
    private final BusinessRegistrationService registrationService;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final BusinessInvitationService invitationService;
    private final EmployeeInvitationService employeeInvitationService;
    private final boolean openRegistration;

    public AuthController(BusinessRegistrationService registrationService,
                          AuthenticationManager authenticationManager,
                          JwtService jwtService,
                          BusinessInvitationService invitationService,
                          EmployeeInvitationService employeeInvitationService,
                          @Value("${app.registration.open:true}") boolean openRegistration) {
        this.registrationService = registrationService;
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.invitationService = invitationService;
        this.employeeInvitationService = employeeInvitationService;
        this.openRegistration = openRegistration;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody BusinessRegistrationService.RegisterRequest request) {
        if (!openRegistration) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(new ErrorResponse("Business registration requires an invitation"));
        }
        BusinessRegistrationService.AuthenticatedBusinessRegistration registration = registrationService.registerBusiness(request);
        Business business = registration.business();
        User user = registration.user();

        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(business, user, registration.token()));
    }

    @PostMapping("/invitations/accept")
    public ResponseEntity<AuthResponse> acceptInvitation(@Valid @RequestBody AcceptInvitationRequest request) {
        BusinessInvitationService.AcceptedInvitation accepted = invitationService.acceptInvitation(request.token(), request.password());
        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(accepted.business(), accepted.owner(), accepted.token()));
    }

    @PostMapping("/employee-invitations/accept")
    public ResponseEntity<AuthResponse> acceptEmployeeInvitation(@Valid @RequestBody AcceptInvitationRequest request) {
        EmployeeInvitationService.AcceptedEmployee accepted = employeeInvitationService.acceptInvitation(request.token(), request.password());
        User user = accepted.user();
        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(user.getBusiness(), user, accepted.token()));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        Authentication authentication;
        try {
            authentication = authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(
                    request.email().trim().toLowerCase(Locale.ROOT), request.password()));
        } catch (AuthenticationException ex) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new ErrorResponse("Invalid email or password"));
        }

        User user = ((CustomUserPrincipal) authentication.getPrincipal()).getUser();
        return ResponseEntity.ok(toResponse(user.getBusiness(), user, jwtService.generateToken(user)));
    }

    private AuthResponse toResponse(Business business, User user, String token) {
        BusinessSummary businessSummary = business == null ? null : new BusinessSummary(
                business.getId().toString(), business.getName(), business.getEmail(), business.getPhone(), business.getStatus());
        return new AuthResponse(
                businessSummary,
                new UserSummary(user.getId().toString(), user.getEmail(), user.getFullName(), user.getRole().name()),
                token);
    }

    public record AcceptInvitationRequest(@NotBlank String token,
                                          @NotBlank @Size(min = 12, max = 72) String password) {}
    public record LoginRequest(@NotBlank @Email @Size(max = 255) String email,
                               @NotBlank @Size(max = 72) String password) {}
    public record ErrorResponse(String message) {}
    public record AuthResponse(BusinessSummary business, UserSummary user, String token) {}
    public record BusinessSummary(String id, String name, String email, String phone, String status) {}
    public record UserSummary(String id, String email, String fullName, String role) {}
}
