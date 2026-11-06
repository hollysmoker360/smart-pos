package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.PaymentAttempt;
import com.trixx.scanflow.domain.RetailOrder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface PaymentAttemptRepository extends JpaRepository<PaymentAttempt, UUID> {
    Optional<PaymentAttempt> findByOrderAndIdempotencyKey(RetailOrder order, String idempotencyKey);
}
