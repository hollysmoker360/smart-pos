package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.EmployeeInvitation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface EmployeeInvitationRepository extends JpaRepository<EmployeeInvitation, UUID> {
    Optional<EmployeeInvitation> findByTokenHash(String tokenHash);
}
