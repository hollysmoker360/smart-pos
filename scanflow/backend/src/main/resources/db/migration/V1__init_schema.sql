CREATE TABLE businesses (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE branches (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    business_id UUID NOT NULL REFERENCES businesses(id),
    name VARCHAR(255) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'KES',
    timezone VARCHAR(64) NOT NULL DEFAULT 'Africa/Nairobi',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    phone_scanning_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    smart_trolley_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    cashier_pos_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    guest_checkout_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    business_id UUID REFERENCES businesses(id),
    email VARCHAR(255),
    phone VARCHAR(50),
    password_hash VARCHAR(255),
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(64) NOT NULL,
    tenant_scope VARCHAR(64) NOT NULL DEFAULT 'BUSINESS',
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (business_id, email),
    UNIQUE (business_id, phone)
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    user_id UUID NOT NULL REFERENCES users(id),
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE business_onboarding_checklist (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    business_id UUID NOT NULL REFERENCES businesses(id),
    owner_user_id UUID NOT NULL REFERENCES users(id),
    step_name VARCHAR(120) NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (business_id, step_name)
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    business_id UUID NOT NULL REFERENCES businesses(id),
    sku VARCHAR(128) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    brand VARCHAR(128),
    category VARCHAR(128),
    barcode VARCHAR(128),
    unit_of_measure VARCHAR(32) DEFAULT 'UNIT',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    standard_price NUMERIC(12,2) NOT NULL DEFAULT 0,
    tax_rate NUMERIC(7,4) NOT NULL DEFAULT 0,
    cost_price NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (business_id, sku),
    UNIQUE (business_id, barcode)
);

CREATE TABLE shopping_sessions (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    business_id UUID NOT NULL REFERENCES businesses(id),
    branch_id UUID NOT NULL REFERENCES branches(id),
    user_id UUID REFERENCES users(id),
    session_type VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE basket_items (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    session_id UUID NOT NULL REFERENCES shopping_sessions(id),
    product_id UUID NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL,
    line_total NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (session_id, product_id)
);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    business_id UUID NOT NULL REFERENCES businesses(id),
    branch_id UUID NOT NULL REFERENCES branches(id),
    session_id UUID REFERENCES shopping_sessions(id),
    order_number VARCHAR(64) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'DRAFT',
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    currency CHAR(3) NOT NULL DEFAULT 'KES',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (business_id, order_number)
);

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    order_id UUID NOT NULL REFERENCES orders(id),
    product_id UUID NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL,
    tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    line_total NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payment_attempts (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    order_id UUID NOT NULL REFERENCES orders(id),
    provider VARCHAR(32) NOT NULL,
    provider_reference VARCHAR(255),
    amount NUMERIC(12,2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'KES',
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    payload VARCHAR(2000),
    idempotency_key VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (order_id, idempotency_key)
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT RANDOM_UUID(),
    business_id UUID REFERENCES businesses(id),
    user_id UUID REFERENCES users(id),
    action VARCHAR(255) NOT NULL,
    entity_type VARCHAR(255),
    entity_id VARCHAR(255),
    details VARCHAR(2000),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_branches_business_id ON branches(business_id);
CREATE INDEX idx_users_business_id ON users(business_id);
CREATE INDEX idx_products_business_id ON products(business_id);
CREATE INDEX idx_sessions_business_branch ON shopping_sessions(business_id, branch_id);
CREATE INDEX idx_orders_business_status ON orders(business_id, status);
CREATE INDEX idx_payment_attempts_order_id ON payment_attempts(order_id);
CREATE INDEX idx_audit_logs_business_id ON audit_logs(business_id);
