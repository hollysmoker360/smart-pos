package com.trixx.scanflow.repository;

import com.trixx.scanflow.domain.Business;
import com.trixx.scanflow.domain.RetailOrder;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface RetailOrderRepository extends JpaRepository<RetailOrder, UUID> {
    Optional<RetailOrder> findByBusinessAndIdempotencyKey(Business business, String idempotencyKey);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select retailOrder from RetailOrder retailOrder where retailOrder.business = :business and retailOrder.idempotencyKey = :key")
    Optional<RetailOrder> findByBusinessAndIdempotencyKeyForUpdate(@Param("business") Business business,
                                                                   @Param("key") String key);
}
