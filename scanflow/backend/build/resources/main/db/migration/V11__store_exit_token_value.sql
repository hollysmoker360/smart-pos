ALTER TABLE exit_tokens ADD COLUMN token_value VARCHAR(255);
UPDATE exit_tokens SET token_value = '' WHERE token_value IS NULL;
ALTER TABLE exit_tokens ALTER COLUMN token_value SET NOT NULL;

CREATE INDEX idx_exit_tokens_status ON exit_tokens(status);
