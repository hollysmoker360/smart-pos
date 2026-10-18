package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.ShoppingSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ShoppingSessionRepository extends JpaRepository<ShoppingSession, Long> {
    Optional<ShoppingSession> findByTrolleyIdAndSessionStatus(Long trolleyId, String sessionStatus);
    List<ShoppingSession> findByCustomerIdAndSessionStatus(Long customerId, String sessionStatus);
}
