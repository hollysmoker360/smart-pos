ALTER TABLE shopping_sessions
    ADD COLUMN guest_access_token_hash VARCHAR(64);

CREATE UNIQUE INDEX uq_shopping_sessions_guest_access_token_hash
    ON shopping_sessions (guest_access_token_hash)
    WHERE guest_access_token_hash IS NOT NULL;

CREATE INDEX idx_shopping_sessions_branch_created
    ON shopping_sessions (branch_id, created_at);
