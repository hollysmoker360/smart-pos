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

@Service
public class BusinessRegistrationService {
    private final BusinessRepository businessRepository;
    private final BranchRepository branchRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public BusinessRegistrationService(BusinessRepository businessRepository,
                                      BranchRepository branchRepository,
                                      UserRepository userRepository,
                                      PasswordEncoder passwordEncoder,
                                      JwtService jwtService) {
        this.businessRepository = businessRepository;
        this.branchRepository = branchRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthenticatedBusinessRegistration registerBusiness(RegisterRequest request) {
        if (userRepository.findByEmail(request.email()).isPresent()) {
            throw new IllegalArgumentException("An account with that email already exists");
        }

        Business business = new Business(request.businessName(), request.email(), request.phone());
        business = businessRepository.save(business);

        Branch branch = new Branch(business, "Main Branch");
        branchRepository.save(branch);

        String encodedPassword = passwordEncoder.encode(request.password());
        User user = new User(business, request.email(), request.phone(), request.ownerName(), encodedPassword, UserRole.OWNER);
        user = userRepository.save(user);

        String token = jwtService.generateToken(user);

        return new AuthenticatedBusinessRegistration(
                business,
                user,
                token
        );
    }

    public record RegisterRequest(String businessName, String email, String phone, String ownerName, String password) {}

    public record AuthenticatedBusinessRegistration(Business business, User user, String token) {}
}
