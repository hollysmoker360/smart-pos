package com.trixx.smartpos.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "inventory_balances")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InventoryBalance {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "branch_id", nullable = false)
    private UUID branchId;

    @Column(name = "product_id", nullable = false)
    private UUID productId;

    @Column(name = "available_quantity", nullable = false)
    private BigDecimal availableQuantity = BigDecimal.ZERO;

    @Column(name = "reserved_quantity", nullable = false)
    private BigDecimal reservedQuantity = BigDecimal.ZERO;

    @Column(name = "damaged_quantity", nullable = false)
    private BigDecimal damagedQuantity = BigDecimal.ZERO;

    @Column(name = "reorder_level", nullable = false)
    private BigDecimal reorderLevel = new BigDecimal("10.000");

    @Column(name = "updated_at")
    private Instant updatedAt = Instant.now();
}
