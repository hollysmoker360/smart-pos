package com.trixx.scanflow.service;

import com.trixx.scanflow.domain.Branch;
import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.EmployeeInvitation;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.domain.UserBranchAccess;
import com.trixx.scanflow.domain.UserRole;
import com.trixx.scanflow.repository.BranchRepository;
import com.trixx.scanflow.repository.EmployeeInvitationRepository;
import com.trixx.scanflow.repository.UserBranchAccessRepository;
import com.trixx.scanflow.repository.UserRepository;
import com.trixx.scanflow.security.JwtService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class EmployeeInvitationService {
    private static final Duration INVITATION_LIFETIME = Duration.ofDays(3);
    private static final Set<UserRole> INVITABLE_ROLES = Set.of(
            UserRole.BUSINESS_ADMIN, UserRole.BRANCH_MANAGER, UserRole.CASHIER,
            UserRole.INVENTORY_OFFICER, UserRole.FINANCE_OFFICER, UserRole.AUDITOR);

    private final EmployeeInvitationRepository invitationRepository;
    private final UserBranchAccessRepository branchAccessRepository;
    private final BranchRepository branchRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuditLogService auditLogService;
    private final InvitationTokenCodec tokenCodec;
    private final String publicBaseUrl;

    public EmployeeInvitationService(EmployeeInvitationRepository invitationRepository,
                                     UserBranchAccessRepository branchAccessRepository,
                                     BranchRepository branchRepository,
                                     UserRepository userRepository,
                                     PasswordEncoder passwordEncoder,
                                     JwtService jwtService,
                                     AuditLogService auditLogService,
                                     InvitationTokenCodec tokenCodec,
                                     @Value("${app.public-url}") String publicBaseUrl) {
        this.invitationRepository = invitationRepository;
        this.branchAccessRepository = branchAccessRepository;
        this.branchRepository = branchRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.auditLogService = auditLogService;
        this.tokenCodec = tokenCodec;
        this.publicBaseUrl = publicBaseUrl.replaceAll("/$", "");
    }

    @Transactional
    public CreatedEmployeeInvitation createInvitation(User actor, CreateEmployeeInvitationRequest request) {
        if (actor.getBusiness() == null || !Set.of(UserRole.OWNER, UserRole.BUSINESS_ADMIN).contains(actor.getRole())) {
            throw new IllegalArgumentException("Business administrator access is required");
        }
        if (!INVITABLE_ROLES.contains(request.role())) {
            throw new IllegalArgumentException("Role cannot be assigned through an employee invitation");
        }
        String email = request.email().trim().toLowerCase(Locale.ROOT);
        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("An account with that email already exists");
        }

        Set<UUID> requestedBranchIds = new HashSet<>(request.branchIds());
        List<Branch> branches = branchRepository.findByBusiness(actor.getBusiness()).stream()
                .filter(branch -> requestedBranchIds.contains(branch.getId()))
                .toList();
        if (branches.isEmpty() || branches.size() != requestedBranchIds.size()) {
            throw new IllegalArgumentException("Every assigned branch must belong to your business");
        }

        String rawToken = tokenCodec.issueToken();
        Instant expiresAt = Instant.now().plus(INVITATION_LIFETIME);
        EmployeeInvitation invitation = invitationRepository.save(new EmployeeInvitation(
                actor.getBusiness(), actor, request.fullName().trim(), email, request.phone().trim(), request.role(),
                tokenCodec.hash(rawToken), expiresAt, new HashSet<>(branches)));
        auditLogService.record(actor.getBusiness(), actor, "EMPLOYEE_INVITATION_CREATED", "EmployeeInvitation",
                invitation.getId().toString(), email + "|" + request.role());

        return new CreatedEmployeeInvitation(invitation.getId().toString(), email, request.role().name(),
                publicBaseUrl + "/accept-employee-invitation?token=" + rawToken, expiresAt,
                branches.stream().map(branch -> branch.getId().toString()).toList());
    }

    @Transactional
    public AcceptedEmployee acceptInvitation(String rawToken, String rawPassword) {
        if (rawToken == null || rawToken.isBlank()) {
            throw new IllegalArgumentException("Invitation token is required");
        }
        EmployeeInvitation invitation = invitationRepository.findByTokenHash(tokenCodec.hash(rawToken.trim()))
                .orElseThrow(() -> new IllegalArgumentException("Invitation is invalid or expired"));
        if (invitation.getAcceptedAt() != null || !invitation.getExpiresAt().isAfter(Instant.now())) {
            throw new IllegalArgumentException("Invitation is invalid or expired");
        }
        if (userRepository.findByEmail(invitation.getEmail()).isPresent()) {
            throw new IllegalArgumentException("An account with that email already exists");
        }

        User employee = new User(invitation.getBusiness(), invitation.getEmail(), invitation.getPhone(),
                invitation.getFullName(), passwordEncoder.encode(rawPassword), invitation.getRole());
        employee = userRepository.save(employee);
        for (Branch branch : invitation.getBranches()) {
            branchAccessRepository.save(new UserBranchAccess(employee, branch));
        }
        invitation.accept(employee, Instant.now());
        auditLogService.record(invitation.getBusiness(), employee, "EMPLOYEE_INVITATION_ACCEPTED", "User",
                employee.getId().toString(), employee.getRole().name());

        List<String> assignedBranches = invitation.getBranches().stream().map(branch -> branch.getId().toString()).toList();
        return new AcceptedEmployee(employee, jwtService.generateToken(employee), assignedBranches);
    }

    public record CreateEmployeeInvitationRequest(String fullName, String email, String phone, UserRole role,
                                                  List<UUID> branchIds) {}
    public record CreatedEmployeeInvitation(String invitationId, String email, String role, String invitationUrl,
                                            Instant expiresAt, List<String> branchIds) {}
    public record AcceptedEmployee(User user, String token, List<String> branchIds) {}
}
