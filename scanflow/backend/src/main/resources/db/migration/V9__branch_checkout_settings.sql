ALTER TABLE branches
    ADD COLUMN manual_barcode_entry_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN require_staff_exit_verification BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN require_customer_sign_in BOOLEAN NOT NULL DEFAULT FALSE;
