package com.trixx.smartpos.repository;

import com.trixx.smartpos.model.Receipt;
import com.trixx.smartpos.model.ExitToken;
import com.trixx.smartpos.model.ExitEvent;
import com.trixx.smartpos.model.Refund;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ReceiptRepository extends JpaRepository<Receipt, UUID> {
    Optional<Receipt> findByOrderId(UUID orderId);
    Optional<Receipt> findByReceiptNumber(String receiptNumber);
}
