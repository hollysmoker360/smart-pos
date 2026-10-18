-- V2 Advanced Features Schema for TRIXX SmartPOS

CREATE TABLE idempotency_keys (
    key_value VARCHAR(255) PRIMARY KEY,
    tenant_id UUID,
    request_path VARCHAR(255) NOT NULL,
    response_body TEXT,
    response_code INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE outbox_events (
    id UUID PRIMARY KEY,
    event_id VARCHAR(100) NOT NULL UNIQUE,
    event_type VARCHAR(100) NOT NULL,
    event_version INT DEFAULT 1,
    tenant_id UUID,
    branch_id UUID,
    aggregate_id VARCHAR(100),
    correlation_id VARCHAR(100),
    payload TEXT NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed BOOLEAN DEFAULT FALSE,
    retry_count INT DEFAULT 0,
    last_attempt_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE processed_events (
    event_id VARCHAR(100) PRIMARY KEY,
    consumer_name VARCHAR(100) NOT NULL,
    processed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inventory_reservations (
    id UUID PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES shopping_sessions(id) ON DELETE CASCADE,
    branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    reserved_quantity DECIMAL(12,3) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    released BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE price_versions (
    id UUID PRIMARY KEY,
    branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    price DECIMAL(12,2) NOT NULL,
    version INT NOT NULL DEFAULT 1,
    changed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE promotion_redemptions (
    id UUID PRIMARY KEY,
    promotion_id UUID NOT NULL REFERENCES promotions(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    discount_applied DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payment_reconciliations (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    payment_attempt_id UUID REFERENCES payment_attempts(id) ON DELETE SET NULL,
    mpesa_receipt VARCHAR(100),
    expected_amount DECIMAL(12,2) NOT NULL,
    received_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    reconciled_by VARCHAR(50) DEFAULT 'AUTO',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notification_jobs (
    id UUID PRIMARY KEY,
    tenant_id UUID,
    recipient_type VARCHAR(50) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    channel VARCHAR(50) NOT NULL,
    subject VARCHAR(255),
    content TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING',
    retry_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE data_quality_checks (
    id UUID PRIMARY KEY,
    tenant_id UUID,
    check_type VARCHAR(100) NOT NULL,
    severity VARCHAR(50) DEFAULT 'WARNING',
    details TEXT NOT NULL,
    resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE integration_health (
    id UUID PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(50) NOT NULL,
    last_check_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    error_details TEXT
);
