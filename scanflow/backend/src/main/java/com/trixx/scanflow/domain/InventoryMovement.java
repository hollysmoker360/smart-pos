package com.trixx.scanflow.domain;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "inventory_movements")
public class InventoryMovement {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "business_id", nullable = false)
    private Business business;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "branch_id", nullable = false)
    private Branch branch;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private RetailOrder order;

    @Column(name = "movement_type", nullable = false)
    private String movementType;

    @Column(name = "quantity_delta", nullable = false)
    private Integer quantityDelta;

    @Column(nullable = false)
    private String reason;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    protected InventoryMovement() {
    }

    public InventoryMovement(Business business, Branch branch, Product product, User user,
                             RetailOrder order, String movementType, Integer quantityDelta, String reason) {
        this.business = business;
        this.branch = branch;
        this.product = product;
        this.user = user;
        this.order = order;
        this.movementType = movementType;
        this.quantityDelta = quantityDelta;
        this.reason = reason;
    }

    public UUID getId() { return id; }
    public Integer getQuantityDelta() { return quantityDelta; }
    public String getMovementType() { return movementType; }
    public Instant getCreatedAt() { return createdAt; }
}
