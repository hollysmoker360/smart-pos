CREATE TABLE employee_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id),
    invited_by_user_id UUID NOT NULL REFERENCES users(id),
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    role VARCHAR(64) NOT NULL CHECK (role IN ('BUSINESS_ADMIN', 'BRANCH_MANAGER', 'CASHIER', 'INVENTORY_OFFICER', 'FINANCE_OFFICER', 'AUDITOR')),
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    accepted_at TIMESTAMP,
    accepted_by_user_id UUID REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE employee_invitation_branches (
    invitation_id UUID NOT NULL REFERENCES employee_invitations(id) ON DELETE CASCADE,
    branch_id UUID NOT NULL REFERENCES branches(id),
    PRIMARY KEY (invitation_id, branch_id)
);

CREATE TABLE user_branch_access (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    branch_id UUID NOT NULL REFERENCES branches(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, branch_id)
);

CREATE INDEX idx_employee_invitations_business_id ON employee_invitations(business_id);
CREATE INDEX idx_employee_invitations_expiry ON employee_invitations(expires_at);
CREATE INDEX idx_user_branch_access_branch_id ON user_branch_access(branch_id);
