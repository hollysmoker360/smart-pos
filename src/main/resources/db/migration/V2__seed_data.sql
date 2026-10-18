-- V2__seed_data.sql

INSERT INTO roles (id, name, description) VALUES
(1, 'ROLE_PLATFORM_ADMIN', 'TRIXX Platform Administrator'),
(2, 'ROLE_SUPERMARKET_OWNER', 'Supermarket Owner'),
(3, 'ROLE_BRANCH_MANAGER', 'Branch Manager'),
(4, 'ROLE_FINANCE', 'Accountant / Finance Manager'),
(5, 'ROLE_INVENTORY_MANAGER', 'Inventory Manager'),
(6, 'ROLE_LOSS_PREVENTION', 'Loss Prevention Specialist'),
(7, 'ROLE_SUPERVISOR', 'Branch Supervisor'),
(8, 'ROLE_CASHIER', 'Cashier'),
(9, 'ROLE_CUSTOMER', 'Customer User'),
(10, 'ROLE_SUPPORT', 'TRIXX Support Agent');

INSERT INTO tenants (id, name, code, status) VALUES
(1, 'Naivas Supermarkets Kenya', 'NAIVAS', 'ACTIVE'),
(2, 'Quickmart Retail Chain', 'QUICKMART', 'ACTIVE');

INSERT INTO branches (id, tenant_id, name, code, address, city, operating_hours, status) VALUES
(1, 1, 'Naivas Westlands Store', 'NAIVAS-WESTLANDS', 'Waiyaki Way', 'Nairobi', '08:00 - 21:00', 'ACTIVE'),
(2, 1, 'Naivas Kilimani Store', 'NAIVAS-KILIMANI', 'Argwings Kodhek Rd', 'Nairobi', '08:00 - 22:00', 'ACTIVE'),
(3, 2, 'Quickmart Lavington', 'QUICKMART-LAVINGTON', 'James Gichuru Rd', 'Nairobi', '08:00 - 21:30', 'ACTIVE');

INSERT INTO users (id, tenant_id, branch_id, role_id, username, email, phone_number, password_hash, full_name, status) VALUES
(1, 1, 1, 1, 'admin', 'admin@trixx.co.ke', '+254700000001', '$2a$10$e8W/a7eO49d5hT3eJv0GmeE83R11h5QZl1v8sU6RkLpY4G2X0R3Sm', 'TRIXX Platform Admin', 'ACTIVE'),
(2, 1, 1, 2, 'owner_naivas', 'owner@naivas.co.ke', '+254711000001', '$2a$10$e8W/a7eO49d5hT3eJv0GmeE83R11h5QZl1v8sU6RkLpY4G2X0R3Sm', 'John Naivas', 'ACTIVE'),
(3, 1, 1, 3, 'bm_westlands', 'bm.westlands@naivas.co.ke', '+254722000001', '$2a$10$e8W/a7eO49d5hT3eJv0GmeE83R11h5QZl1v8sU6RkLpY4G2X0R3Sm', 'Alice Westlands Manager', 'ACTIVE'),
(4, 1, 1, 7, 'sup_westlands', 'sup.westlands@naivas.co.ke', '+254733000001', '$2a$10$e8W/a7eO49d5hT3eJv0GmeE83R11h5QZl1v8sU6RkLpY4G2X0R3Sm', 'Sam Supervisor', 'ACTIVE'),
(5, 1, 1, 8, 'cashier_westlands', 'cashier.westlands@naivas.co.ke', '+254744000001', '$2a$10$e8W/a7eO49d5hT3eJv0GmeE83R11h5QZl1v8sU6RkLpY4G2X0R3Sm', 'Claire Cashier', 'ACTIVE'),
(6, 1, 1, 9, 'customer_ken', 'kenya.customer@gmail.com', '+254712345678', '$2a$10$e8W/a7eO49d5hT3eJv0GmeE83R11h5QZl1v8sU6RkLpY4G2X0R3Sm', 'Ken Otieno', 'ACTIVE');

INSERT INTO trolley_devices (id, tenant_id, branch_id, device_code, qr_code_hash, battery_level, firmware_version, scanner_status, connectivity_status, device_status) VALUES
(1, 1, 1, 'TRL-WEST-001', 'QR-TRL-WEST-001-HASH', 95, 'v1.2.0', 'OK', 'ONLINE', 'AVAILABLE'),
(2, 1, 1, 'TRL-WEST-002', 'QR-TRL-WEST-002-HASH', 88, 'v1.2.0', 'OK', 'ONLINE', 'AVAILABLE'),
(3, 1, 1, 'TRL-WEST-003', 'QR-TRL-WEST-003-HASH', 100, 'v1.2.0', 'OK', 'ONLINE', 'AVAILABLE');

INSERT INTO products (id, tenant_id, sku, name, description, category, aisle_location, expected_weight_grams, weight_tolerance_grams, status) VALUES
(1, 1, 'MILK-BROOK-1L', 'Brookside Fresh Milk 1L', '1 Litre Pure Fresh Milk', 'Dairy', 'Aisle 1 - Dairy', 1030.00, 30.00, 'ACTIVE'),
(2, 1, 'BREAD-FEST-400G', 'Festive Bread White 400g', 'Soft Sliced White Bread', 'Bakery', 'Aisle 2 - Bakery', 400.00, 20.00, 'ACTIVE'),
(3, 1, 'SUGAR-KAB-2KG', 'Kabras Sugar 2kg', 'Pure Fine Grain Sugar 2kg', 'Pantry', 'Aisle 3 - Grains & Sugar', 2000.00, 50.00, 'ACTIVE'),
(4, 1, 'TEA-KETEPA-500G', 'Ketepa Tea Leaves 500g', 'Premium Loose Black Tea', 'Pantry', 'Aisle 3 - Beverages', 500.00, 15.00, 'ACTIVE'),
(5, 1, 'OIL-ELIANT-2L', 'Elianto Corn Oil 2L', 'Pure Corn Oil 2 Litres', 'Pantry', 'Aisle 4 - Oils', 1850.00, 40.00, 'ACTIVE');

INSERT INTO product_barcodes (id, product_id, barcode, barcode_type) VALUES
(1, 1, '6161100001011', 'EAN13'),
(2, 2, '6161100002028', 'EAN13'),
(3, 3, '6161100003035', 'EAN13'),
(4, 4, '6161100004042', 'EAN13'),
(5, 5, '6161100005059', 'EAN13');

INSERT INTO branch_prices (id, tenant_id, branch_id, product_id, selling_price, tax_rate, effective_from, status) VALUES
(1, 1, 1, 1, 120.00, 0.00, CURRENT_TIMESTAMP, 'ACTIVE'),
(2, 1, 1, 2, 65.00, 0.00, CURRENT_TIMESTAMP, 'ACTIVE'),
(3, 1, 1, 3, 310.00, 16.00, CURRENT_TIMESTAMP, 'ACTIVE'),
(4, 1, 1, 4, 240.00, 16.00, CURRENT_TIMESTAMP, 'ACTIVE'),
(5, 1, 1, 5, 680.00, 16.00, CURRENT_TIMESTAMP, 'ACTIVE');

INSERT INTO price_versions (id, product_id, branch_id, price, tax_rate, version_hash) VALUES
(1, 1, 1, 120.00, 0.00, 'PV-1-120.00'),
(2, 2, 1, 65.00, 0.00, 'PV-2-65.00'),
(3, 3, 1, 310.00, 16.00, 'PV-3-310.00'),
(4, 4, 1, 240.00, 16.00, 'PV-4-240.00'),
(5, 5, 1, 680.00, 16.00, 'PV-5-680.00');

INSERT INTO inventory_balances (id, tenant_id, branch_id, product_id, quantity_on_hand, quantity_reserved) VALUES
(1, 1, 1, 1, 150, 0),
(2, 1, 1, 2, 80, 0),
(3, 1, 1, 3, 200, 0),
(4, 1, 1, 4, 100, 0),
(5, 1, 1, 5, 45, 0);

INSERT INTO integration_health (id, service_name, status, last_checked_at, details) VALUES
(1, 'Safaricom Daraja M-Pesa API', 'UP', CURRENT_TIMESTAMP, 'Sandbox environment responsive'),
(2, 'Trolley Device Gateway', 'UP', CURRENT_TIMESTAMP, 'Gateway listening on WebSocket/MQTT');
