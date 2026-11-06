package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.BusinessInvitation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface BusinessInvitationRepository extends JpaRepository<BusinessInvitation, UUID> {
    Optional<BusinessInvitation> findByTokenHash(String tokenHash);
}
