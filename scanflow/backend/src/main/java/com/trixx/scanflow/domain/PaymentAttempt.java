package com.trixx.scanflow.domain;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "payment_attempts", uniqueConstraints = @UniqueConstraint(columnNames = {"order_id", "idempotency_key"}))
public class PaymentAttempt {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "order_id", nullable = false)
    private RetailOrder order;

    @Column(nullable = false)
    private String provider;

    @Column(name = "provider_reference")
    private String providerReference;

    @Column(nullable = false)
    private BigDecimal amount;

    @Column(nullable = false, length = 3, columnDefinition = "CHAR(3)")
    private String currency;

    @Column(nullable = false)
    private String status;

    @Column(name = "idempotency_key", nullable = false)
    private String idempotencyKey;

    @Column(name = "cash_received")
    private BigDecimal cashReceived;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    protected PaymentAttempt() {
    }

    public PaymentAttempt(RetailOrder order, String provider, String providerReference,
                          BigDecimal amount, String currency, String status,
                          String idempotencyKey, BigDecimal cashReceived) {
        this.order = order;
        this.provider = provider;
        this.providerReference = providerReference;
        this.amount = amount;
        this.currency = currency;
        this.status = status;
        this.idempotencyKey = idempotencyKey;
        this.cashReceived = cashReceived;
    }

    public UUID getId() { return id; }
    public RetailOrder getOrder() { return order; }
    public String getProvider() { return provider; }
    public BigDecimal getAmount() { return amount; }
    public String getStatus() { return status; }
    public BigDecimal getCashReceived() { return cashReceived; }
}
