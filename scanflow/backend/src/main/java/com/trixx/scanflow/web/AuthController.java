package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.User;
import com.trixx.scanflow.service.BusinessRegistrationService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
    private final BusinessRegistrationService registrationService;

    public AuthController(BusinessRegistrationService registrationService) {
        this.registrationService = registrationService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Validated @RequestBody BusinessRegistrationService.RegisterRequest request) {
        BusinessRegistrationService.AuthenticatedBusinessRegistration registration = registrationService.registerBusiness(request);
        Business business = registration.business();
        User user = registration.user();

        AuthResponse response = new AuthResponse(
                new BusinessSummary(business.getId().toString(), business.getName(), business.getEmail(), business.getPhone(), business.getStatus()),
                new UserSummary(user.getId().toString(), user.getEmail(), user.getFullName(), user.getRole().name()),
                registration.token()
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    public record AuthResponse(BusinessSummary business, UserSummary user, String token) {}
    public record BusinessSummary(String id, String name, String email, String phone, String status) {}
    public record UserSummary(String id, String email, String fullName, String role) {}
}
