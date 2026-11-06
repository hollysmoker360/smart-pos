package com.trixx.scanflow.domain;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "exit_tokens", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"order_id"}),
        @UniqueConstraint(columnNames = {"token_hash"})
})
public class ExitToken {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "order_id", nullable = false)
    private RetailOrder order;

    @Column(name = "token_hash", nullable = false, length = 64)
    private String tokenHash;

    @Column(name = "token_value", nullable = false, length = 255)
    private String tokenValue;

    @Column(nullable = false)
    private String status = "ACTIVE";

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    protected ExitToken() {
    }

    public ExitToken(RetailOrder order, String tokenHash, String tokenValue, Instant expiresAt) {
        this.order = order;
        this.tokenHash = tokenHash;
        this.tokenValue = tokenValue;
        this.expiresAt = expiresAt;
    }

    public UUID getId() { return id; }
    public RetailOrder getOrder() { return order; }
    public String getTokenHash() { return tokenHash; }
    public String getTokenValue() { return tokenValue; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getExpiresAt() { return expiresAt; }
    public Instant getCreatedAt() { return createdAt; }
}
