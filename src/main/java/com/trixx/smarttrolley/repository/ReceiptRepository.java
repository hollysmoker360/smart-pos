package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.Receipt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ReceiptRepository extends JpaRepository<Receipt, Long> {
    Optional<Receipt> findByOrderId(Long orderId);
    Optional<Receipt> findByReceiptNumber(String receiptNumber);
}
