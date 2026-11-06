package com.trixx.scanflow.service;

import com.trixx.scanflow.domain.Branch;
import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.domain.UserRole;
import com.trixx.scanflow.repository.BranchRepository;
import com.trixx.scanflow.repository.BusinessRepository;
import com.trixx.scanflow.repository.UserRepository;
import com.trixx.scanflow.security.JwtService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.Locale;

@Service
public class BusinessRegistrationService {
    private final BusinessRepository businessRepository;
    private final BranchRepository branchRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuditLogService auditLogService;

    public BusinessRegistrationService(BusinessRepository businessRepository,
                                      BranchRepository branchRepository,
                                      UserRepository userRepository,
                                      PasswordEncoder passwordEncoder,
                                      JwtService jwtService,
                                      AuditLogService auditLogService) {
        this.businessRepository = businessRepository;
        this.branchRepository = branchRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.auditLogService = auditLogService;
    }

    @Transactional
    public AuthenticatedBusinessRegistration registerBusiness(RegisterRequest request) {
        String email = request.email().trim().toLowerCase(Locale.ROOT);
        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("An account with that email already exists");
        }

        Business business = new Business(request.businessName().trim(), email, request.phone().trim());
        business = businessRepository.save(business);

        Branch branch = new Branch(business, "Main Branch");
        branchRepository.save(branch);

        String encodedPassword = passwordEncoder.encode(request.password());
        User user = new User(business, email, request.phone().trim(), request.ownerName().trim(), encodedPassword, UserRole.OWNER);
        user = userRepository.save(user);

        auditLogService.record(business, user, "BUSINESS_REGISTERED", "Business",
                business.getId().toString(), "Business owner registered");
        auditLogService.record(business, user, "BRANCH_CREATED", "Branch",
                branch.getId().toString(), "Initial branch created during business registration");

        String token = jwtService.generateToken(user);

        return new AuthenticatedBusinessRegistration(
                business,
                user,
                token
        );
    }

    public record RegisterRequest(@NotBlank @Size(max = 255) String businessName,
                                  @NotBlank @Email @Size(max = 255) String email,
                                  @NotBlank @Size(max = 50) String phone,
                                  @NotBlank @Size(max = 255) String ownerName,
                                  @NotBlank @Size(min = 12, max = 72) String password) {}

    public record AuthenticatedBusinessRegistration(Business business, User user, String token) {}
}
