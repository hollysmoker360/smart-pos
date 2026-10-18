package com.trixx.smartpos.repository;

import com.trixx.smartpos.model.ExitToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ExitTokenRepository extends JpaRepository<ExitToken, UUID> {
    Optional<ExitToken> findByTokenHash(String tokenHash);
    Optional<ExitToken> findByOrderId(UUID orderId);
}
