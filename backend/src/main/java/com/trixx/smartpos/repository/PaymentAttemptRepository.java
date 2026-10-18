package com.trixx.smartpos.repository;

import com.trixx.smartpos.model.PaymentAttempt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface PaymentAttemptRepository extends JpaRepository<PaymentAttempt, UUID> {
    Optional<PaymentAttempt> findByCheckoutRequestId(String checkoutRequestId);
    Optional<PaymentAttempt> findByMerchantRequestIdAndCheckoutRequestId(String merchantRequestId, String checkoutRequestId);
}
