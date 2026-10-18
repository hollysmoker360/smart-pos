package com.trixx.smartpos.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "tenant_id", nullable = false)
    private UUID tenantId;

    @Column(nullable = false)
    private String sku;

    @Column(nullable = false)
    private String name;

    private String description;
    private String category;
    private String brand;

    @Column(name = "package_size")
    private String packageSize;

    @Column(name = "unit_of_measure")
    private String unitOfMeasure = "PCS";

    @Column(name = "tax_rate")
    private BigDecimal taxRate = new BigDecimal("16.00");

    @Column(nullable = false)
    private String status = "ACTIVE";

    @Column(name = "created_at")
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at")
    private Instant updatedAt = Instant.now();
}
