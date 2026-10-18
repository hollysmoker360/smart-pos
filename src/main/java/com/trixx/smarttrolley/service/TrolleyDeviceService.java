package com.trixx.smarttrolley.service;

import com.trixx.smarttrolley.domain.*;
import com.trixx.smarttrolley.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class TrolleyDeviceService {

    private final TrolleyDeviceRepository trolleyDeviceRepository;
    private final DeviceEventRepository deviceEventRepository;

    public TrolleyDeviceService(TrolleyDeviceRepository trolleyDeviceRepository,
                                DeviceEventRepository deviceEventRepository) {
        this.trolleyDeviceRepository = trolleyDeviceRepository;
        this.deviceEventRepository = deviceEventRepository;
    }

    @Transactional
    public TrolleyDevice claimTrolleyByQr(String qrCodeHash) {
        TrolleyDevice device = trolleyDeviceRepository.findByQrCodeHash(qrCodeHash)
                .orElseThrow(() -> new IllegalArgumentException("INVALID_TROLLEY_QR: Trolley device not found for QR hash"));

        if ("MAINTENANCE".equalsIgnoreCase(device.getDeviceStatus())) {
            throw new IllegalStateException("TROLLEY_UNAVAILABLE: Trolley is currently under maintenance");
        }

        device.setLastPingAt(LocalDateTime.now());
        return trolleyDeviceRepository.save(device);
    }

    @Transactional
    public DeviceEvent recordDeviceEvent(String eventId, String deviceCode, Long sessionId,
                                          String eventType, String barcode, Long sequenceNumber,
                                          LocalDateTime timestamp, String rawPayload) {
        var existingEvent = deviceEventRepository.findByEventId(eventId);
        if (existingEvent.isPresent()) {
            return existingEvent.get();
        }

        TrolleyDevice device = trolleyDeviceRepository.findByDeviceCode(deviceCode)
                .orElseThrow(() -> new IllegalArgumentException("DEVICE_NOT_FOUND: Device " + deviceCode + " not recognized"));

        device.setLastPingAt(LocalDateTime.now());
        trolleyDeviceRepository.save(device);

        DeviceEvent event = new DeviceEvent();
        event.setEventId(eventId);
        event.setDevice(device);
        event.setSessionId(sessionId);
        event.setEventType(eventType);
        event.setBarcode(barcode);
        event.setSequenceNumber(sequenceNumber);
        event.setDeviceTimestamp(timestamp != null ? timestamp : LocalDateTime.now());
        event.setRawPayload(rawPayload);
        event.setProcessed(true);

        return deviceEventRepository.save(event);
    }
}
