package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.Business;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface BusinessRepository extends JpaRepository<Business, UUID> {
    Optional<Business> findByEmail(String email);
    Optional<Business> findByPhone(String phone);
}
