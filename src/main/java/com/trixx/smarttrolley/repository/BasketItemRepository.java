package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.BasketItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BasketItemRepository extends JpaRepository<BasketItem, Long> {
    List<BasketItem> findByBasketId(Long basketId);
    Optional<BasketItem> findByBasketIdAndProductId(Long basketId, Long productId);
}
