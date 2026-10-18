package com.trixx.smartpos.repository;

import com.trixx.smartpos.model.Order;
import com.trixx.smartpos.model.PaymentAttempt;
import com.trixx.smartpos.model.IdempotencyKey;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface OrderRepository extends JpaRepository<Order, UUID> {
    Optional<Order> findByOrderNumber(String orderNumber);
}
