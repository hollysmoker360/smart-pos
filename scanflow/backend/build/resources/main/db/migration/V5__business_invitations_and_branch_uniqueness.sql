ALTER TABLE branches
    ADD CONSTRAINT uq_branches_business_name UNIQUE (business_id, name);

CREATE TABLE business_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_name VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    owner_email VARCHAR(255) NOT NULL,
    owner_phone VARCHAR(50) NOT NULL,
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    accepted_at TIMESTAMP,
    created_by_user_id UUID NOT NULL REFERENCES users(id),
    accepted_business_id UUID REFERENCES businesses(id),
    accepted_by_user_id UUID REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_business_invitations_expiry ON business_invitations(expires_at);
