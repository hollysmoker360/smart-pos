ALTER TABLE orders ADD COLUMN idempotency_key VARCHAR(255);
ALTER TABLE orders ADD COLUMN request_fingerprint VARCHAR(64);
CREATE UNIQUE INDEX uq_orders_business_idempotency
    ON orders (business_id, idempotency_key);

ALTER TABLE payment_attempts ADD COLUMN cash_received NUMERIC(12, 2);

CREATE TABLE inventory_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id),
    branch_id UUID NOT NULL REFERENCES branches(id),
    product_id UUID NOT NULL REFERENCES products(id),
    user_id UUID NOT NULL REFERENCES users(id),
    order_id UUID REFERENCES orders(id),
    movement_type VARCHAR(32) NOT NULL,
    quantity_delta INTEGER NOT NULL CHECK (quantity_delta <> 0),
    reason VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inventory_movements_branch_product
    ON inventory_movements (business_id, branch_id, product_id, created_at);
