package com.trixx.scanflow.domain;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "branches")
public class Branch {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "business_id", nullable = false)
    private Business business;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String currency = "KES";

    @Column(nullable = false)
    private String timezone = "Africa/Nairobi";

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    @Column(name = "phone_scanning_enabled", nullable = false)
    private boolean phoneScanningEnabled = true;

    @Column(name = "smart_trolley_enabled", nullable = false)
    private boolean smartTrolleyEnabled = false;

    @Column(name = "cashier_pos_enabled", nullable = false)
    private boolean cashierPosEnabled = true;

    @Column(name = "guest_checkout_enabled", nullable = false)
    private boolean guestCheckoutEnabled = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public Branch() {
    }

    public Branch(Business business, String name) {
        this.business = business;
        this.name = name;
    }

    public UUID getId() {
        return id;
    }

    public Business getBusiness() {
        return business;
    }

    public void setBusiness(Business business) {
        this.business = business;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getTimezone() {
        return timezone;
    }

    public void setTimezone(String timezone) {
        this.timezone = timezone;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public boolean isPhoneScanningEnabled() {
        return phoneScanningEnabled;
    }

    public void setPhoneScanningEnabled(boolean phoneScanningEnabled) {
        this.phoneScanningEnabled = phoneScanningEnabled;
    }

    public boolean isSmartTrolleyEnabled() {
        return smartTrolleyEnabled;
    }

    public void setSmartTrolleyEnabled(boolean smartTrolleyEnabled) {
        this.smartTrolleyEnabled = smartTrolleyEnabled;
    }

    public boolean isCashierPosEnabled() {
        return cashierPosEnabled;
    }

    public void setCashierPosEnabled(boolean cashierPosEnabled) {
        this.cashierPosEnabled = cashierPosEnabled;
    }

    public boolean isGuestCheckoutEnabled() {
        return guestCheckoutEnabled;
    }

    public void setGuestCheckoutEnabled(boolean guestCheckoutEnabled) {
        this.guestCheckoutEnabled = guestCheckoutEnabled;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }
}
