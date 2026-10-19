package com.trixx.scanflow.web;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.repository.BusinessRepository;
import com.trixx.scanflow.security.CustomUserPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class BusinessController {
    private final BusinessRepository businessRepository;

    public BusinessController(BusinessRepository businessRepository) {
        this.businessRepository = businessRepository;
    }

    @GetMapping("/businesses/me")
    public ResponseEntity<BusinessSummary> getCurrentBusiness(@AuthenticationPrincipal CustomUserPrincipal principal) {
        Business business = principal.getUser().getBusiness();
        if (business == null) {
            throw new IllegalArgumentException("Business not found");
        }

        return ResponseEntity.ok(new BusinessSummary(
                business.getId().toString(),
                business.getName(),
                business.getEmail(),
                business.getPhone(),
                business.getStatus()
        ));
    }

    public record BusinessSummary(String id, String name, String email, String phone, String status) {}
}
