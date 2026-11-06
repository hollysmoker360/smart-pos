package com.trixx.scanflow.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "business_invitations")
public class BusinessInvitation {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "business_name", nullable = false)
    private String businessName;

    @Column(name = "owner_name", nullable = false)
    private String ownerName;

    @Column(name = "owner_email", nullable = false)
    private String ownerEmail;

    @Column(name = "owner_phone", nullable = false)
    private String ownerPhone;

    @Column(name = "token_hash", nullable = false, unique = true, length = 64)
    private String tokenHash;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "accepted_at")
    private Instant acceptedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_user_id", nullable = false)
    private User createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "accepted_business_id")
    private Business acceptedBusiness;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "accepted_by_user_id")
    private User acceptedBy;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    protected BusinessInvitation() {
    }

    public BusinessInvitation(String businessName, String ownerName, String ownerEmail, String ownerPhone,
                              String tokenHash, Instant expiresAt, User createdBy) {
        this.businessName = businessName;
        this.ownerName = ownerName;
        this.ownerEmail = ownerEmail;
        this.ownerPhone = ownerPhone;
        this.tokenHash = tokenHash;
        this.expiresAt = expiresAt;
        this.createdBy = createdBy;
    }

    public void accept(Business business, User user, Instant acceptedAt) {
        this.acceptedBusiness = business;
        this.acceptedBy = user;
        this.acceptedAt = acceptedAt;
    }

    public UUID getId() { return id; }
    public String getBusinessName() { return businessName; }
    public String getOwnerName() { return ownerName; }
    public String getOwnerEmail() { return ownerEmail; }
    public String getOwnerPhone() { return ownerPhone; }
    public String getTokenHash() { return tokenHash; }
    public Instant getExpiresAt() { return expiresAt; }
    public Instant getAcceptedAt() { return acceptedAt; }
    public User getCreatedBy() { return createdBy; }
    public Business getAcceptedBusiness() { return acceptedBusiness; }
    public User getAcceptedBy() { return acceptedBy; }
    public Instant getCreatedAt() { return createdAt; }
}
