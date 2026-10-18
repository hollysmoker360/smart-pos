package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.PaymentAttempt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaymentAttemptRepository extends JpaRepository<PaymentAttempt, Long> {
    Optional<PaymentAttempt> findByPaymentReference(String paymentReference);
    Optional<PaymentAttempt> findByCheckoutRequestId(String checkoutRequestId);
}
