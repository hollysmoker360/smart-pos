package com.trixx.smarttrolley.repository;

import com.trixx.smarttrolley.domain.DeviceEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DeviceEventRepository extends JpaRepository<DeviceEvent, Long> {
    Optional<DeviceEvent> findByEventId(String eventId);
    List<DeviceEvent> findByDeviceIdOrderBySequenceNumberDesc(Long deviceId);
}
