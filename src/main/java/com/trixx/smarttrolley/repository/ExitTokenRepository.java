package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.ExitToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ExitTokenRepository extends JpaRepository<ExitToken, Long> {
    Optional<ExitToken> findByOrderId(Long orderId);
    Optional<ExitToken> findByTokenHash(String tokenHash);
}
