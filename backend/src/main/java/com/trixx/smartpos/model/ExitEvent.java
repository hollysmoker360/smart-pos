package com.trixx.smartpos.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "exit_events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExitEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "exit_token_id", nullable = false)
    private UUID exitTokenId;

    @Column(name = "branch_id", nullable = false)
    private UUID branchId;

    @Column(name = "staff_user_id")
    private UUID staffUserId;

    @Column(nullable = false)
    private String result; // APPROVED, REJECTED, INSPECTION_REQUIRED

    @Column(name = "inspection_performed")
    @Builder.Default
    private Boolean inspectionPerformed = false;

    private String notes;

    @Column(name = "created_at")
    @Builder.Default
    private Instant createdAt = Instant.now();
}
