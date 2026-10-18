package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.TrolleyDevice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TrolleyDeviceRepository extends JpaRepository<TrolleyDevice, Long> {
    Optional<TrolleyDevice> findByDeviceCode(String deviceCode);
    Optional<TrolleyDevice> findByQrCodeHash(String qrCodeHash);
    List<TrolleyDevice> findByBranchId(Long branchId);
}
