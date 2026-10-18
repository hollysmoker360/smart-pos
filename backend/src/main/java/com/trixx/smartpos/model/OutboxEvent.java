package com.trixx.smartpos.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "outbox_events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OutboxEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "event_id", nullable = false, unique = true)
    private String eventId;

    @Column(name = "event_type", nullable = false)
    private String eventType;

    @Column(name = "event_version")
    @Builder.Default
    private Integer eventVersion = 1;

    @Column(name = "tenant_id")
    private UUID tenantId;

    @Column(name = "branch_id")
    private UUID branchId;

    @Column(name = "aggregate_id")
    private String aggregateId;

    @Column(name = "correlation_id")
    private String correlationId;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String payload;

    @Column(name = "occurred_at")
    @Builder.Default
    private Instant occurredAt = Instant.now();

    @Builder.Default
    private Boolean processed = false;

    @Column(name = "retry_count")
    @Builder.Default
    private Integer retryCount = 0;

    @Column(name = "last_attempt_at")
    private Instant lastAttemptAt;
}
