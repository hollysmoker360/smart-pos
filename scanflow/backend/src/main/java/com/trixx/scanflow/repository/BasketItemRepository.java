package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.BasketItem;
import com.trixx.scanflow.domain.Product;
import com.trixx.scanflow.domain.ShoppingSession;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BasketItemRepository extends JpaRepository<BasketItem, UUID> {
    Optional<BasketItem> findBySessionAndProduct(ShoppingSession session, Product product);
    List<BasketItem> findBySession(ShoppingSession session);
}
