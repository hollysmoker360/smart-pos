package com.trixx.smartpos.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "branch_prices")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BranchPrice {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "branch_id", nullable = false)
    private UUID branchId;

    @Column(name = "product_id", nullable = false)
    private UUID productId;

    @Column(nullable = false)
    private BigDecimal price;

    @Column(name = "cost_price")
    private BigDecimal costPrice = BigDecimal.ZERO;

    @Column(name = "effective_from")
    private Instant effectiveFrom = Instant.now();

    @Column(name = "effective_to")
    private Instant effectiveTo;
}
