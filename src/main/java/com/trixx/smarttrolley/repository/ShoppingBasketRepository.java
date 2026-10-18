package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.ShoppingBasket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ShoppingBasketRepository extends JpaRepository<ShoppingBasket, Long> {
    Optional<ShoppingBasket> findBySessionId(Long sessionId);
}
