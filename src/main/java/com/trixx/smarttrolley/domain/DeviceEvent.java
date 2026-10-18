package com.trixx.smarttrolley.domain;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "device_events")
public class DeviceEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String eventId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "device_id", nullable = false)
    private TrolleyDevice device;

    private Long sessionId;

    @Column(nullable = false)
    private String eventType;

    private String barcode;

    @Column(nullable = false)
    private Long sequenceNumber;

    @Column(nullable = false)
    private LocalDateTime deviceTimestamp;

    @Column(columnDefinition = "TEXT")
    private String rawPayload;

    private Boolean processed = false;
    private LocalDateTime createdAt = LocalDateTime.now();

    public DeviceEvent() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getEventId() { return eventId; }
    public void setEventId(String eventId) { this.eventId = eventId; }

    public TrolleyDevice getDevice() { return device; }
    public void setDevice(TrolleyDevice device) { this.device = device; }

    public Long getSessionId() { return sessionId; }
    public void setSessionId(Long sessionId) { this.sessionId = sessionId; }

    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }

    public String getBarcode() { return barcode; }
    public void setBarcode(String barcode) { this.barcode = barcode; }

    public Long getSequenceNumber() { return sequenceNumber; }
    public void setSequenceNumber(Long sequenceNumber) { this.sequenceNumber = sequenceNumber; }

    public LocalDateTime getDeviceTimestamp() { return deviceTimestamp; }
    public void setDeviceTimestamp(LocalDateTime deviceTimestamp) { this.deviceTimestamp = deviceTimestamp; }

    public String getRawPayload() { return rawPayload; }
    public void setRawPayload(String rawPayload) { this.rawPayload = rawPayload; }

    public Boolean getProcessed() { return processed; }
    public void setProcessed(Boolean processed) { this.processed = processed; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
