package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.ExitToken;
import com.trixx.scanflow.domain.RetailOrder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface ExitTokenRepository extends JpaRepository<ExitToken, UUID> {
    Optional<ExitToken> findByOrder(RetailOrder order);
    Optional<ExitToken> findByTokenHash(String tokenHash);
}
