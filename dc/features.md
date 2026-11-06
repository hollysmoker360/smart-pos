I have chosen scanflow give also the icon

Your chosen brand is ScanFlow by TRIXX Technologies — with the tagline “Scan. Shop. Go.”

The icon combines a shopping trolley, barcode scanning brackets and motion lines to represent fast, connected shopping. The green and charcoal palette gives it a modern retail-technology identity.

full system details especially features and how things flow
ScanFlow — Complete System Specification
A TRIXX Technologies product | Retail scanning, smart shopping, point of sale and store management

Amazon Dash Cart enables customers to skip checkout lane
ScanFlow is a retail technology platform that allows customers to scan products using their phones or a SmartTrolley, manage a shopping basket, pay digitally, and complete checkout with less friction. It also gives shop owners tools to manage products, stock, staff, sales, payments and business performance.

The most important design principle is that all shopping methods share one central system. A customer scanning on a phone, a shopper using a SmartTrolley, and a cashier serving a customer must use the same trusted product catalogue, pricing rules, inventory records and order-processing logic.

1. System overview
ScanFlow Customer Experience
Phone scanning · SmartTrolley · Cashier checkout

ScanFlow API & Business Rules
Identity · Branch rules · Catalogue · Basket · Checkout · Payments · Permissions

PostgreSQL

Products, prices, orders, stock, audit records

Security & controls

Tenant isolation, staff roles, device authentication

Payment providers

M-Pesa, supported card providers and cash POS

Analytics & reporting

Sales, margins, stock movement and device health

Supported shopping modes
Barcode Scanner Grocery Store at Corrina Davis blog
1. ScanFlow Phone

Customers scan product barcodes with a mobile camera. Suitable for minimarkets, groceries and small shops without dedicated trolley hardware.

Woolworths rolls out massive change to checkout experience in Australian first - Yahoo News Australia
2. ScanFlow SmartTrolley

A trolley-mounted Android touchscreen and barcode scanner allow customers to scan items while shopping. The controller sends scan events to the backend; it does not calculate prices or totals.

Market Programı Nasıl Kullanılır? | Posingo | Posingo
3. ScanFlow POS

Staff scan items at a conventional checkout counter. The same catalogue, inventory and order system handles cashier transactions.

2. User roles and permissions
Each account should see only the features appropriate to its role. Access must be enforced by the backend, not just hidden in the interface.

Role

Main capabilities

Platform super administrator

Manage retail businesses, subscriptions, platform configuration, support and system health

Business owner

Manage company settings, branches, staff, products, reports, pricing policies and permissions

Branch manager

Oversee branch operations, stock, sales, devices, cashiers and approvals

Inventory officer

Receive stock, transfers, stock counts, adjustments and supplier records

Cashier

Create and complete permitted POS sales, handle approved payment methods and print or send receipts

Customer

Scan products, manage a basket, pay, access receipts and view their own shopping history

Exit/verification attendant

Verify eligible paid orders and inspect selected baskets without accessing unnecessary customer data

Finance officer

Review payments, settlements, refunds, reconciliation and financial reports

Auditor

View authorized records, reports and audit trails without changing operational data

Supplier

View assigned purchase orders, submit fulfilment information and maintain permitted supplier details

Support technician

Diagnose authorized devices and connection problems without unrestricted access to customer or payment data

A small shop can combine roles—for example, the owner may also be the cashier. Larger supermarkets can enforce separation of duties, such as requiring a manager to approve high-value refunds.

3. Complete feature modules
A. Business registration and onboarding
This module gets a retail business ready to use ScanFlow.

Features:

Register a retail business and its legal/business details.

Create the owner account and verify email or phone.

Select business type: supermarket, minimarket, grocery, convenience store or retail chain.

Create one or more branches.

Configure each branch's currency, timezone, tax settings and receipt details.

Invite staff and assign permissions.

Import products from CSV or spreadsheet.

Configure barcode scanning, payment methods, checkout and receipt preferences.

Register cashier terminals and SmartTrolleys.

Set low-stock thresholds and notification preferences.

Offer a guided setup checklist showing what remains before the shop can start selling.

Flow: Business registration → account verification → business profile → branch setup → product import → staff invitations → payment configuration → device setup → test transaction → go live.

The owner should be able to skip hardware setup entirely when starting with phone scanning or a normal cashier POS.

B. Product catalogue and barcode management
This is the central product database used by every shopping mode.

Features:

Product name, description, SKU and product image.

One or multiple barcodes per product, where appropriate.

Category, brand, size, unit of measure and pack quantity.

Standard retail price and branch-specific price.

Cost price, supplier and margin reporting, restricted to authorized roles.

Tax category and applicable tax rules.

Product variants, such as size, flavour, colour or pack.

Weighted products, such as fruit, vegetables and meat.

Product bundles and multipacks.

Promotion eligibility and effective dates.

Expiry date and batch tracking for applicable goods.

Product availability per branch.

Duplicate-barcode detection and barcode import validation.

Product archive rather than destructive deletion when historical transactions exist.

How barcode lookup works

A phone camera, SmartTrolley scanner or cashier scanner reads a barcode.

ScanFlow sends the barcode, branch and shopping-session context to the backend.

The backend checks the active catalogue and the branch's product availability.

It retrieves the authorized product description, price, tax treatment and applicable promotion rules.

The customer interface displays the server-confirmed result.

If the barcode is unknown, the product is inactive or the branch does not sell it, ScanFlow shows an understandable error instead of guessing a price.

A barcode identifies a product; it does not itself contain the trusted current price.

C. Inventory and stock management
Features:

Opening stock and stock receipts.

Stock transfers between branches.

Purchase orders and supplier deliveries.

Stock adjustments with mandatory reasons.

Physical stock counts and reconciliation.

Low-stock alerts and suggested reorder quantities.

Batch and expiry tracking.

Damaged, expired, returned and quarantined stock.

Stock movement history.

Stock valuation and inventory reports.

Reserved stock and available-to-sell quantities.

Negative-stock prevention, configurable for specific operational scenarios.

Stock flow

Purchase order or approved opening stock
Delivery received and quantity checked
Stock receipt recorded in inventory ledger
Sale, return, transfer or adjustment creates a stock movement
Updated available stock, audit trail and alerts
Stock should be updated through a transaction ledger rather than simply overwriting a number. That makes it possible to investigate discrepancies and explain why the stock changed.

D. Phone-based shopping
This is the feature that makes ScanFlow practical for small shops without dedicated hardware.

Customer features:

Scan a QR code displayed at the shop entrance or checkout.

Confirm the correct shop and branch.

Start a shopping session.

Scan product barcodes using the phone camera.

Search products if a barcode cannot be read.

View product images, descriptions, prices and available promotions.

Add, remove or change quantities.

See the basket, estimated total and applicable charges.

Identify products that require staff assistance.

Save an active basket during temporary app interruptions.

Checkout using enabled payment methods.

View the final receipt and purchase history.

Resume a session after an interruption when the session remains valid.

The app should request camera access only when scanning is needed. Customers should not need to manually pair their phones with a trolley in phone-only mode.

Customer phone flow

01
Select the shop

Scan the shop QR or choose an authorized branch.

02
Start a session

The server creates a session and applies the branch's rules.

03
Scan products

Read each barcode and send the scan event to the backend.

04
Review the basket

Show confirmed product details, quantities and current server-calculated totals.

05
Checkout

Revalidate prices, stock, promotions, quantities and checkout eligibility.

06
Pay

Use an enabled method, such as a supported M-Pesa integration.

07
Verify and finish

Confirm payment, finalize the order, issue a receipt and perform any required exit check.

E. SmartTrolley management
SmartTrolley combines an Android touchscreen, barcode scanner, Wi-Fi connection and a device controller.

Features:

QR-assisted trolley identification.

Secure device registration and pairing.

One-tap connection diagnostics.

Device health monitoring and last-seen timestamps.

Battery status where supported.

Wi-Fi connectivity and backend connectivity status.

Scanner connection and test scan.

Live basket updates.

Customer session lock and session release.

Device assignment to a branch.

Remote configuration and approved software-update management.

Device maintenance history.

Lost-device revocation and replacement workflows.

Offline scan-event buffering and safe retry.

Staff-only setup mode and secure Wi-Fi provisioning.

Trolley connection flow

A staff member opens the ScanFlow admin app or device management screen.

The trolley displays a pairing QR code or short-lived pairing code.

An authorized staff member confirms the branch and pairs the device.

The backend issues device credentials or a scoped device token.

The trolley connects to the approved Wi-Fi network and ScanFlow API.

The controller tests scanner input and reports device health.

The Android display confirms that the trolley is ready.

The customer starts a shopping session.

Scan events are sent to the backend and the latest basket is displayed.

When the session ends, the trolley is released and becomes available again.

The QR code must not expose Wi-Fi passwords, permanent device secrets or unrestricted access tokens. Device credentials must be revocable.

F. Shared basket and pricing engine
This module ensures that every channel calculates the same basket correctly.

Features:

Add, remove and update quantities.

Prevent accidental duplicate scans.

Validate product and branch eligibility.

Apply eligible promotions.

Calculate taxes according to configured rules.

Validate price changes before checkout.

Handle restricted, weighed or staff-verified items.

Recalculate the basket when an item is removed or its quantity changes.

Maintain a basket version to prevent conflicting updates.

Record scan events and relevant changes for support and fraud investigation.

Important rule: the phone, tablet, trolley controller and barcode scanner must never be the authority for prices or final totals. The backend calculates all monetary amounts. Interfaces can show a provisional estimate, but the final payable amount must be recalculated and confirmed by the backend before payment.

G. Checkout and order management
Features:

Revalidate the entire basket at checkout.

Check stock availability and branch rules.

Apply valid promotions and taxes.

Generate a unique order number.

Create an order snapshot containing product descriptions, quantities, prices, taxes and discounts at the time of purchase.

Support phone, trolley and cashier-originated orders.

Prevent duplicate order creation on retries.

Track order status and payment status separately.

Support cancellation before completion under defined rules.

Handle failed, abandoned and expired checkout sessions.

Provide refund and return workflows with appropriate approvals.

Possible order states:

DRAFT → PENDING_PAYMENT → PAID → COMPLETED

Alternative states include PAYMENT_FAILED, CANCELLED, EXPIRED, REFUND_PENDING and PARTIALLY_REFUNDED.

Payment status must not be inferred from the order state alone. A payment can be pending while an order exists, and a delayed provider callback must not cause duplicate fulfilment.

H. Payments and M-Pesa
For Kenya, M-Pesa can be a core payment method, subject to merchant onboarding, provider access and integration requirements.

Features:

Initiate a payment request for a confirmed order.

Present the customer with the correct amount and order reference.

Track pending, confirmed, failed, cancelled and reversed payments.

Process provider callbacks securely.

Verify callback authenticity and reconcile with provider records.

Handle duplicate callbacks and delayed confirmations.

Record transaction references and settlement information.

Provide an authorized refund workflow.

Reconcile ScanFlow orders against provider transactions.

Support additional payment providers through a common payment interface.

Payment flow

Backend creates the order and calculates the final amount
Backend initiates the payment with the provider
Customer authorizes payment on the provider's approved channel
Provider confirmation is received and verified
Payment recorded, order finalized, receipt issued and checkout/exit rules evaluated
A successful request to initiate an M-Pesa payment is not proof that the customer paid. ScanFlow must wait for a verified provider confirmation or use the provider's approved transaction-status and reconciliation procedures.

Cash and card payments can be handled through the cashier POS, with payment recording and reconciliation appropriate to each method.

I. Exit verification and loss prevention
Self-scanning makes shopping faster, but it introduces a risk that scanned items will not match the items physically carried out.

Features:

Exit verification screen for authorized staff.

Order QR code or short-lived verification pass.

Server-side confirmation that the order is eligible for exit.

Single-use pass validation.

Random or risk-based basket checks.

Full basket verification when required.

Flagging of missing scans, unusual quantities or unresolved exceptions.

Verification outcome, attendant ID and timestamp.

Escalation to a manager.

Clear fallback to normal cashier checkout.

Exit flow: Customer finishes checkout → payment/order status is verified → ScanFlow issues an eligible verification pass → attendant scans the pass → backend validates the order and pass → any required physical check occurs → exit is approved or an exception is raised.

The pass should be short-lived, bound to the correct order and branch, and stored securely on the server. A QR code or receipt by itself cannot prove that the physical basket matches the paid order.

J. Cashier POS
Features:

Barcode scanner and manual product lookup.

Quick product search and category shortcuts.

Cash, supported mobile money and configured payment methods.

Cash received and change due.

Receipt printing or digital receipt delivery.

Customer identification where appropriate and consented.

Discounts controlled by permissions.

Suspended sales and resume-sale workflows.

Returns, exchanges and refunds under approval rules.

Till opening/closing and cash reconciliation.

Cashier shift summaries.

Price override and void audit logs.

Barcode label printing where supported.

A cashier sale must use the same backend catalogue, pricing and inventory ledger as phone and trolley purchases. It should not become a separate system with its own inconsistent stock count.

4. Admin dashboard
The admin dashboard is the operational centre of ScanFlow. It should adapt to the user's permissions and the business's size.

RetailPro POS Dashboard by Mostafa Kamal on Dribbble
Dashboard overview
The landing page should show:

Today's sales and comparison with a previous period.

Number of completed orders.

Average order value.

Gross profit estimates, if cost data is complete and authorized.

Low-stock and out-of-stock products.

Pending payments and reconciliation exceptions.

Active shopping sessions.

Online, offline and faulty SmartTrolleys.

Top-selling products.

Sales by branch and payment method.

Returns, refunds and cancelled orders.

Alerts requiring action.

Every metric should be calculated from a documented source, with date filters, timezone handling and permission checks. Pending payments should not be counted as completed sales.

Admin navigation structure
Overview

KPIs, alerts and daily performance

Business & branches

Business profile, branch settings and operating rules

Products & pricing

Catalogue, barcodes, prices and promotions

Inventory

Stock receipts, counts, transfers and suppliers

Shopping operations

Active sessions, baskets and orders

Devices & SmartTrolleys

Pairing, health, connection and maintenance

Payments & finance

Transactions, settlement, refunds and reconciliation

Customers & loyalty

Profiles, consent, points and purchase history

Staff & permissions

Invitations, roles, approvals and shifts

Reports & analytics

Sales, margin, stock and customer insights

Security & audit

Login history, privileged actions and suspicious activity

Settings & integrations

Taxes, receipts, payment providers, APIs and notifications

Business configuration and feature switches
Each branch should have its own settings, with optional defaults inherited from the parent business.

Setting

What it controls

Phone scanning

Allow customers to scan products using their phones

SmartTrolley

Enable registered trolley devices

Cashier POS

Enable conventional staff-operated checkout

Customer account requirement

Require login or allow an eligible guest session

Payments

Enable only configured and approved payment methods

Exit verification

Choose required, risk-based or not applicable, subject to store policy

Promotions

Enable specific discount types and applicable conditions

Offline operation

Define safe fallback behaviour during connection outages

Receipts

Choose digital, printed or both

Inventory policy

Define stock reservation and negative-stock handling

Loyalty

Enable points, rewards and redemption rules

Notifications

Configure alerts for stock, payments and device faults

Example: A small grocery can enable phone scanning and cashier POS while leaving SmartTrolley disabled. A supermarket can enable all three. Both still use the same backend and inventory.

A feature switch must never bypass a security check, payment validation or inventory control.

5. Customers, loyalty and engagement
Customer account features
Optional account registration, subject to branch policy.

Phone or email verification.

Active shopping sessions.

Past orders and digital receipts.

Saved preferences and consent controls.

Secure account recovery.

Support and order issue reporting.

Opt-in notifications about receipts, rewards and relevant offers.

Loyalty features
Points earned on eligible completed purchases.

Rewards and coupon codes.

Member pricing.

Tiered loyalty levels.

Expiry rules and redemption limits.

Refund-related points reversal.

Fraud checks for unusual reward activity.

Loyalty liability and redemption reporting.

Loyalty calculations should happen on the backend, with a ledger for earning and redemption. Refunds must not leave customers with rewards for purchases that were reversed.

Promotions engine
Support:

Percentage discounts.

Fixed-amount discounts.

Buy-one-get-one offers.

Multi-buy pricing.

Product and category promotions.

Coupon codes.

Member-only offers.

Branch-specific offers.

Start and end times.

Usage limits and stacking rules.

At checkout, the backend must determine which promotions apply, their priority and whether they can be combined. The customer should see a clear breakdown of discounts rather than an unexplained total change.

6. Supplier and purchasing management
For larger retailers, add a supplier portal and purchasing workflow.

Features:

Supplier registration and approval.

Supplier product codes and catalogue mapping.

Purchase requisitions and purchase orders.

Approval thresholds.

Expected delivery dates.

Goods received notes.

Partial deliveries and damaged-stock recording.

Supplier invoices and reference matching.

Cost-price history.

Supplier performance reporting.

Reorder suggestions based on stock and sales.

Flow: Low-stock alert or manual request → purchase requisition → manager approval → purchase order → supplier fulfilment → delivery inspection → stock receipt → invoice matching → finance reconciliation.

A suggested reorder should not automatically place an order unless the business has explicitly configured and authorized that behaviour.

7. Reports and business intelligence
The reporting module should answer practical questions, not merely display attractive charts.

Sales and revenue

Sales by hour, day, product, category, branch, cashier and shopping channel; average basket size and sales trends.

Inventory performance

Stock turnover, days of cover, slow-moving products, stockouts, wastage, expiry exposure and adjustment discrepancies.

Financial reporting

Payment method breakdown, refunds, fees, settlement discrepancies, gross sales, discounts, tax and estimated gross margin.

Operations

Trolley uptime, connection failures, abandoned sessions, scan errors, checkout duration and payment success rates.

Reports should support date ranges, branch filters, CSV export and permission-based access. Profit and margin calculations must account for incomplete cost records, discounts, returns and the chosen accounting definitions.

Advanced analytics can later introduce demand forecasting, reorder recommendations, unusual transaction detection and promotion performance analysis. These should be recommendations with explanations, not automatic financial decisions without authorization.

8. Notifications and exception handling
ScanFlow should notify the right person when something needs attention.

Owner/manager: unusual refunds, repeated stock discrepancies, sales exceptions and branch performance alerts.

Inventory staff: low stock, pending deliveries and expiring products.

Finance: unmatched payments, settlement differences and pending refunds.

Cashier: payment result, scan error, price change or required approval.

Customer: payment status, receipt, eligible reward and relevant order updates.

Device technician: trolley offline, scanner failure, low battery or software-update failure.

Use in-app notifications first, with optional email, SMS or supported push notifications. Deduplicate repeated alerts and allow severity thresholds so staff are not overwhelmed.

9. How the complete system works together
Consider a customer who shops using their phone, pays with M-Pesa and leaves through an exit checkpoint.

End-to-end shopping journey
Branch and session selection

ScanFlow resolves the branch QR code, checks that the branch is active, applies its shopping rules and creates a server-side session.

Barcode scan

The phone reads the barcode and sends a uniquely identified scan event. The backend validates the session and product.

Basket update

The backend adds the item or handles a deliberate quantity change, applies relevant rules and returns the confirmed basket.

Checkout validation

ScanFlow rechecks the complete basket, branch prices, promotion eligibility, taxes, stock and session status. It creates an order with a fixed purchase-time snapshot.

Payment initiation

The backend requests payment through the configured provider and records the payment attempt. The UI shows that payment is pending.

Verified payment

A verified provider confirmation changes the payment record to paid. Duplicate callbacks do not create duplicate orders or inventory movements.

Order finalization

The order is finalized, the stock ledger is updated according to the configured reservation and sale policy, loyalty is calculated if enabled, and the receipt is issued.

Exit check

If required, the attendant verifies the order and any physical basket check. The backend authorizes exit or records an exception.

Reporting and reconciliation

Sales, stock movements and payment records feed the appropriate dashboards. Later settlement reconciliation can identify discrepancies.

What happens when something goes wrong?
Situation

Correct behaviour

Barcode is unknown

Explain that the product was not found; offer search or staff assistance

Wi-Fi disconnects during scanning

Buffer eligible scan events and retry with unique event IDs; clearly indicate that the basket is not current

Product price changes mid-session

Apply the documented price policy and disclose any change before payment

Item is out of stock

Prevent an invalid sale or request an authorized override according to policy

M-Pesa request times out

Keep the payment pending or uncertain while checking provider status; do not blindly initiate a duplicate payment

Payment confirmation arrives twice

Process idempotently and preserve one correct payment outcome

Customer closes the app

Allow secure session recovery if the session is still valid

Trolley is replaced

Revoke old device credentials, pair the replacement and recover only the authorized active session

Exit pass has expired

Revalidate the order and issue a new eligible pass if allowed

Payment is confirmed but order processing fails

Use durable retry and reconciliation workflows to complete processing without charging twice

A refund is approved

Record the refund, update the order and stock only according to the actual return outcome, and reverse applicable loyalty rewards

10. Technical architecture
The system should be built as a modular retail platform rather than several independent applications.

Client applications
Flutter customer app · Flutter POS/admin · Android trolley interface

API gateway / Spring Boot application

HTTPS REST · authentication · validation · rate limiting · authorization

Retail modules

Catalogue, pricing, inventory, basket, checkout, orders

Operations modules

Devices, payments, refunds, reports, notifications

Persistence and background processing

PostgreSQL · Flyway migrations · durable job/outbox processing · optional Redis

External integrations

M-Pesa/payment providers · email/SMS/push · receipt printers · monitoring

Recommended technology stack
Layer

Technology

Purpose

Mobile and web UI

Flutter with Dart

Customer app, staff app, admin web interface and supported Android kiosk UI

Backend

Java with Spring Boot

Business rules, API endpoints, authentication and integrations

Database

PostgreSQL

Products, pricing, inventory, sessions, orders, payments and audit logs

Database migrations

Flyway

Version-controlled schema changes

Authentication

Spring Security with OAuth2/OIDC-compatible identity flows

Secure login, access tokens and role enforcement

API documentation

OpenAPI

Documented, testable endpoints

Device communication

HTTPS REST initially

Scan events, basket updates, pairing and health reports

Live updates

Server-Sent Events or WebSockets where useful

Live basket, order status and device dashboard updates

Background processing

Transactional outbox and durable workers

Payment callbacks, notifications, retries and reconciliation

Cache

Optional Redis

Short-lived caching and distributed coordination where needed

Deployment

Docker and a managed cloud environment

Repeatable deployments and environment isolation

Monitoring

Central logs, metrics, traces and alerts

Troubleshooting, reliability and operational visibility

For the first release, a modular monolith is a sensible architecture: one Spring Boot deployment with well-separated modules and database ownership rules. It is easier to test and maintain than starting with many microservices. Modules can be split later when there is a real scaling or organizational need.

Main backend modules
Identity and access management.

Business tenancy and branch configuration.

Product catalogue and barcode lookup.

Pricing, taxes and promotions.

Inventory and purchasing.

Shopping sessions and baskets.

Checkout and order management.

Payment integration and reconciliation.

SmartTrolley device management.

POS and cashier operations.

Exit verification.

Customers and loyalty.

Reporting and analytics.

Notifications.

Audit, security and support operations.

SaaS subscription and billing management.

11. Database design
The database should be designed around clear business entities, foreign-key relationships, unique constraints and transaction boundaries.

Entity / table

Purpose

businesses

Retail businesses using ScanFlow

branches

Locations, settings and operating rules

users

User identities

memberships

User access to a particular business or branch

roles, permissions

Access control

devices

Registered trolleys, scanners and POS terminals

device_credentials

Revocable device authentication records

products

Central product records

product_barcodes

Barcode-to-product mapping

branch_products

Branch-specific availability and settings

price_lists, product_prices

Effective-dated prices and pricing policies

tax_categories

Configured tax treatment

promotions, promotion_rules

Discounts, eligibility and stacking conditions

inventory_balances

Efficiently queryable stock balance

inventory_movements

Append-oriented stock ledger

suppliers, purchase_orders

Purchasing and receiving

shopping_sessions

Customer, branch and device shopping sessions

scan_events

Idempotent scan history

baskets, basket_items

Active shopping baskets

orders, order_items

Final order and purchase-time item snapshots

payments, payment_attempts

Payment lifecycle and provider references

payment_webhook_events

Deduplicated provider callback processing

refunds

Approved refunds and outcomes

receipts

Receipt references and delivery status

exit_passes, exit_verifications

Exit eligibility and verification records

loyalty_accounts, loyalty_ledger

Reward balances and changes

audit_logs

Important administrative and financial actions

notifications

Delivery state and user alerts

subscriptions, usage_records

SaaS plans and metering

Essential data rules
Business-owned records must be scoped to a tenant and, where applicable, a branch.

Use database constraints to prevent duplicate active barcode mappings where the business rules require uniqueness.

Store monetary values as decimal amounts with a defined currency, never floating-point values.

Preserve the price, tax and discount breakdown used by each completed order.

Store timestamps consistently, normally in UTC, while displaying the branch's local time.

Record inventory changes with their reasons and references.

Use unique provider transaction references and idempotency keys where applicable.

Do not store raw payment PINs, card security codes or unnecessary sensitive payment data.

Use controlled retention and deletion policies for personal information and old operational events.

12. API design
Use versioned REST endpoints with documented request/response schemas, consistent errors and authorization rules.

Illustrative endpoint structure; implementation details and payload schemas should be finalized in the OpenAPI specification.

Area

Example endpoint

Function

Business

POST /api/v1/businesses

Register a business

Branches

POST /api/v1/branches

Create a branch

Products

POST /api/v1/products

Create a product

Barcode lookup

GET /api/v1/products/by-barcode/{code}

Find a product in branch context

Inventory

POST /api/v1/inventory/receipts

Record a stock receipt

Sessions

POST /api/v1/shopping-sessions

Start a shopping session

Scan events

POST /api/v1/device-events/scans

Submit a device scan

Basket

GET /api/v1/shopping-sessions/{id}/basket

Retrieve the current basket

Basket updates

POST /api/v1/shopping-sessions/{id}/items

Add an item or request a controlled update

Checkout

POST /api/v1/shopping-sessions/{id}/checkout

Validate the basket and create an order

Payments

POST /api/v1/orders/{id}/payments/mpesa

Initiate an M-Pesa payment

Payment status

GET /api/v1/orders/{id}/payment-status

Read payment status

Provider callback

POST /api/v1/payments/webhooks/{provider}

Receive a provider event

Devices

POST /api/v1/devices/pairing/start

Start authorized device pairing

Device health

POST /api/v1/devices/{id}/heartbeat

Report device status

Exit

POST /api/v1/exit/verify

Verify an exit pass

Reporting

GET /api/v1/reports/sales

Retrieve authorized sales data

Use pagination for large lists, filters for reports, correlation IDs for tracing, and structured error codes that the front end can translate into useful messages.

Example scan-event request

{
  "eventId": "unique-client-generated-id",
  "deviceId": "authorized-device-id",
  "sessionId": "active-session-id",
  "branchId": "authorized-branch-id",
  "barcode": "0123456789012",
  "eventType": "ITEM_SCANNED",
  "quantity": 1,
  "occurredAt": "2026-10-18T12:30:00Z"
}

The backend must authenticate the device or user, validate the branch and session, and process the event idempotently. It must not trust a client-supplied price or total. The exact event schema should also account for intentional quantity changes, removals and retries.

13. Security, privacy and reliability
These requirements should be built in from the beginning.

Security
HTTPS for all network communication.

Strong password handling, account recovery and optional multi-factor authentication.

Short-lived access tokens and controlled refresh-token rotation.

Server-enforced roles and branch permissions.

Tenant-isolation tests at API and database boundaries.

Device authentication and revocation.

Rate limiting and abuse protection.

Validated provider webhooks and payment reconciliation.

Audit logs for pricing changes, refunds, stock adjustments, permissions and device pairing.

Encrypted backups and protected secrets.

Secure dependency updates and vulnerability scanning.

Session expiry, replay protection and protection against duplicate requests.

Privacy
Collect only personal data needed to operate the service.

Clearly explain camera access and why it is needed.

Avoid retaining raw camera images when barcode decoding alone is sufficient.

Restrict purchase histories to authorized users and purposes.

Define data-retention and deletion rules.

Obtain appropriate consent for marketing and optional tracking.

Provide a process for handling privacy requests and security incidents.

Because ScanFlow is intended for Kenya, the implementation should be reviewed against applicable Kenyan data-protection requirements, including the Data Protection Act, 2019, and relevant ODPC guidance. Tax and payment handling should be validated with the appropriate Kenyan professionals and providers.

Reliability and offline behaviour
Buffer scan events locally when appropriate.

Give every event a unique identifier.

Retry transient failures with backoff.

Display stale or unconfirmed data clearly.

Avoid offline checkout unless a deliberately designed and approved offline-payment policy exists.

Keep durable records of payment attempts and provider callbacks.

Reconcile payment and inventory outcomes after failures.

Monitor service availability, database health and background-job failures.

Test backup restoration rather than merely checking that backups exist.

14. SaaS subscription and platform administration
Because ScanFlow is a TRIXX Technologies product, it can operate as a multi-tenant SaaS platform serving many independent retailers.

Suggested subscription plans
These are proposed plan structures, not current prices.

ScanFlow Starter
Small shops
Phone-based barcode scanning

Basic cashier POS

Product and inventory management

Daily sales reports

Basic receipts and payment integration

ScanFlow Business
Growing retailers
Multiple staff accounts

Advanced promotions and stock management

Customer loyalty

Detailed analytics and reconciliation

Optional SmartTrolley integration

ScanFlow Enterprise
Supermarkets and chains
Multiple branches

Centralized product and pricing policies

Advanced permissions and approvals

Fleet management and device monitoring

Supplier workflows, integrations and advanced reporting

Platform super-admin features
TRIXX's platform administrators should be able to:

Approve and manage retailer accounts.

Configure plans, billing periods and usage limits.

View subscription status and payment failures.

Suspend or reactivate a tenant under controlled procedures.

Monitor system health, API errors and device connectivity.

Manage support cases and authorized troubleshooting access.

Track feature usage and capacity.

Manage platform-wide configuration and integration credentials.

Review security alerts and platform audit logs.

Platform administrators should not automatically have unrestricted access to every customer's purchase history or personal data. Support access should be permission-controlled, logged and limited to the task.

15. User interface and experience design
ScanFlow should look like a professional retail product, not a generic template.

Recommended design system
Brand palette
Deep green

#163D32

Charcoal

#252B29

Soft background

#F5F7F5

White

#FFFFFF

Use green for primary actions and positive states, charcoal for navigation and headings, and neutral backgrounds for information density. Use distinct accessible colours for warnings, failures and pending states.

Customer app screens
Welcome and shop selection.

Scan QR to enter a branch.

Product scanner with torch and manual search.

Product details.

Shopping basket.

Checkout and price breakdown.

Payment status.

Receipt and purchase history.

Help and account settings.

The scan screen should prioritize the camera view, clear scan feedback, a visible basket count and a persistent basket total. Customers should not have to navigate through several menus to scan another item.

Staff and admin screens
Role-based dashboard.

Product and barcode editor.

Inventory list and stock adjustments.

Receiving and supplier orders.

Cashier checkout.

Orders and payment exceptions.

SmartTrolley device list and pairing wizard.

Staff accounts and permissions.

Reports and exports.

Branch configuration and audit history.

SmartTrolley touchscreen
Use large touch targets, clear text, strong contrast and a simple shopping flow. The screen should visibly distinguish:

Ready to scan.

Product successfully added.

Product not recognized.

Connection lost.

Basket needs refreshing.

Checkout in progress.

Payment pending.

Payment confirmed.

Staff assistance required.

Avoid treating a green animation or a successful scan sound as proof of payment. These are only interface signals; the backend remains authoritative.

16. Implementation roadmap
Build ScanFlow in phases so that the first release is usable before the more complicated hardware and enterprise features are added.

Phase 1 — Retail foundation
Must have
Business and branch registration, users and roles, product catalogue, barcodes, branch pricing, inventory ledger, cashier POS, orders and basic reports.

Completion test: a cashier can sell a product, issue a receipt and update the correct branch's stock.

Phase 2 — Phone scanning
First customer release
Shop QR entry, session management, camera barcode scanning, shared baskets, server-side pricing, checkout validation and digital receipts.

Completion test: phone and cashier sales share the same catalogue and inventory without duplicate stock deductions.

Phase 3 — Payments and controls
Financial integrity
M-Pesa integration, provider callback verification, payment reconciliation, refunds, exit verification, audit logs and exception handling.

Completion test: failed, delayed and duplicate payment notifications cannot produce duplicate successful payments or orders.

Phase 4 — SmartTrolley prototype
Hardware integration
Android display, barcode scanner, controller, secure pairing, Wi-Fi diagnostics, device heartbeat, scan retries and fleet dashboard.

Completion test: a trolley can connect, scan, display a server-confirmed basket and recover safely from a temporary disconnection.

Phase 5 — Business growth
Expansion
Promotions, loyalty, supplier portal, purchase orders, multi-branch reporting, subscriptions, forecasting and more integrations.

Completion test: the same retailer can manage multiple branches with controlled access, consistent reporting and auditable stock transfers.

17. Testing plan before launch
ScanFlow should not be considered production-ready until the following areas have been tested.

Test area

Required scenario

Catalogue

Unknown barcode, duplicate barcode, inactive product and branch-specific price

Basket

Repeated scan, quantity change, removal and conflicting updates

Inventory

Two customers attempting to buy the last unit simultaneously

Payments

Success, rejection, timeout, delayed callback, duplicate callback and reversal

Checkout

Price change after scan, expired session and unavailable stock

Devices

Wrong Wi-Fi password, scanner disconnected, low battery and revoked device

Offline recovery

Network drops during a scan, retry after reconnect and stale basket prevention

Security

User attempts to access another branch, tenant or customer's order

Exit

Expired pass, reused pass, unpaid order and valid paid order

Refunds

Duplicate refund request, partial refund and item physically returned versus not returned

Reports

Correct totals across channels, branches, refunds and date ranges

Performance

Concurrent sessions, high-volume scan events and slow payment-provider responses

Recovery

Database restore, background-job restart and payment reconciliation after outage

Start with automated unit tests for business rules, integration tests against a test database, API authorization tests and end-to-end tests. Payment integrations should use provider-approved sandbox environments before live transactions.

18. What makes ScanFlow different?
The strongest differentiator is not just the barcode scanner. It is the combination of flexible checkout methods with one consistent retail operating system.

Small-shop accessibility: a shop can start with phone scanning and a normal POS without buying SmartTrolleys.

Hardware independence: retailers can add SmartTrolleys later without rebuilding the backend.

Unified inventory: every supported channel uses the same inventory ledger.

Verified transactions: orders and payment status are controlled by the backend, not client-side calculations.

Branch flexibility: each store can enable the shopping methods that fit its operations.

Operational visibility: owners can see sales, stock, payments and device health in one place.

Expansion potential: loyalty, supplier workflows, analytics and additional payment providers can be introduced as the business grows.

19. Final definition of the product
ScanFlow is a multi-tenant retail commerce and store-management platform developed by TRIXX Technologies. It connects phone-based product scanning, SmartTrolley-assisted shopping and conventional cashier POS to a shared backend for product catalogues, pricing, inventory, checkout, payment verification, receipts, exit controls, staff permissions and analytics.

Its foundation should be a reliable retail transaction engine. Advanced analytics, loyalty, supplier automation and larger hardware fleets should build on that foundation rather than complicate the first release.

The recommended first milestone is a complete, testable flow from business registration → product setup → phone scan → shared basket → checkout → verified payment → receipt → inventory update. Once that works reliably, add SmartTrolley pairing and hardware integration on top of the same APIs.

ui design

ScanFlow UI/UX Design System
Brand: ScanFlow by TRIXX Technologies
Tagline: Scan. Shop. Go.
Design direction: Premium retail technology, clean layouts, fast workflows and a professional visual identity.

ScanFlow should have three connected interfaces: a simple customer shopping app, an efficient cashier/POS interface, and a comprehensive admin dashboard. The SmartTrolley touchscreen should use a fourth, simplified interface optimized for shopping while standing in a supermarket aisle.

1. Visual identity
ScanFlow
by TRIXX Technologies

Scan. Shop. Go.
A unified shopping experience for phone scanning, smart trolleys and traditional checkout.

Colour palette
Primary green

#163D32

Charcoal

#252B29

Page background

#F5F7F5

Card surface

#FFFFFF

Success surface

#E5F3EB

Warning surface

#FFF0D8

Typography should use Inter or Roboto, with bold but restrained headings, readable body text and clear numeric alignment for prices. Use an 8-point spacing system, rounded cards, subtle borders and minimal shadows. Avoid excessive gradients, oversized headings, glass effects and decorative animations.

2. Customer mobile app
The main customer journey, from opening ScanFlow to completing a purchase.

Future-Proofing E-Commerce App Design Trends and Techniques | Eleven Space
01 — Welcome screen

ScanFlow logo and tagline.

Get Started and Sign In.

Language selection: English and Kiswahili.

Clean introduction without unnecessary registration steps.

Scan & Pay - Coop
02 — Select a shop

Scan the store QR code.

Confirm shop and branch.

Show the branch name before starting.

Provide manual branch selection as a fallback.

Product barcode scanning interaction by mikebarker on Dribbble
03 — Scan products

Camera-first scanning interface.

Torch, manual barcode entry and product search.

Clear success/error feedback.

Basket count visible at all times.

Local grocery delivery app | elGrocer Case Study
04 — Basket

Product image, name, unit price and quantity.

Easy quantity controls and remove action.

Discount breakdown and estimated total.

Prominent Proceed to Checkout button.

Abby Home - App Compras | MWM
05 — Checkout

Final server-confirmed order summary.

M-Pesa and other enabled payment methods.

Clear payment status and retry guidance.

Receipt after verified payment.

Interactive customer-flow preview
Try this simplified prototype to see how the primary shopping flow could work. It is a design demonstration, not a live scanner or payment integration.

ScanFlow
GreenMart · Nairobi branch

0 items
Scan
Basket
Checkout
Ready to scan
In the real app, the camera scans the product barcode here.

Demo products

Fresh milk 500 ml

KES 65

White bread

KES 70

Corn flakes

KES 240

3. Admin dashboard design
SupaPOS – Modern, Human-Centered POS Dashboard by Jahedul Islam on Dribbble
The desktop dashboard should use a fixed dark-green sidebar, a white top bar and a spacious content area.

Sidebar sections

Overview

Business and branches

Products and pricing

Inventory

Orders and shopping sessions

SmartTrolleys and devices

Payments and finance

Customers and loyalty

Staff and permissions

Reports and analytics

Security and audit

Settings and integrations

Dashboard content

Sales today and completed orders.

Average order value.

Pending payments.

Low-stock and out-of-stock alerts.

Sales trend chart.

Top-selling products.

Active shopping sessions.

Online/offline trolley status.

Recent orders and operational alerts.

Use filters for date range and branch. Clicking a KPI or alert should take the administrator directly to the relevant detailed view.

4. SmartTrolley touchscreen design
Woolworths rolls out massive change to checkout experience in Australian first - Yahoo News Australia
The trolley UI should be simpler than the admin dashboard because shoppers use it while moving through aisles.

Home: Start shopping, trolley status and connection indicator.

Scan: Large scan feedback area, product name and confirmed price.

Basket: Items, quantities, removal controls and total.

Checkout: Final review and payment selection.

Payment: Pending, confirmed, failed or retry states.

Help: Request staff assistance and report a scanner issue.

A persistent status area should show whether the trolley is connected. If the basket is stale or the connection is lost, disable checkout until the server has revalidated the session.

5. POS interface for cashiers
Pos Screen designs, themes, templates and downloadable graphic elements on Dribbble
The cashier interface should prioritize speed over decoration.

Search/barcode input automatically focused when appropriate.

Product grid for frequently sold items.

Large cart panel with editable quantities.

Visible subtotal, taxes, discounts and final total.

Quick payment buttons.

Cash received and change due.

Suspend sale and resume sale.

Returns and refunds with permission checks.

Keyboard shortcuts and barcode scanner support.

Clear success and error messages.

6. Responsive design rules
Device

Design priority

Customer phone

Camera scanning, basket and quick checkout

SmartTrolley tablet

Large touch controls and readable status

Cashier desktop

Speed, keyboard navigation and transaction accuracy

Admin desktop

Dense but organized data, filters and analytics

Admin tablet

Responsive tables and simplified management

Small-shop phone

Quick sales, stock lookup and lightweight administration

Use reusable components across the system: buttons, inputs, search fields, status chips, product cards, quantity selectors, tables, confirmation dialogs, empty states and loading skeletons.

7. Design acceptance criteria
Before implementing the full UI, ensure that:

Customers can reach scanning within a few taps.

The basket remains easy to access from every shopping screen.

Prices and payment states are clearly distinguishable.

Every important action has loading, success, failure and retry states.

Admin navigation follows real retail workflows.

SmartTrolley screens are usable with one hand and large touch targets.

Layouts adapt to mobile, tablet and desktop.

Text contrast and keyboard accessibility meet WCAG 2.2 AA targets where applicable.

No screen falsely presents a pending payment as successful.

No client-side interface is treated as the source of truth for prices, inventory or payment confirmation.

Recommended next step: implement the design system and customer phone-scanning flow first, then reuse the same visual components for POS, the admin dashboard and the SmartTrolley interface.

the trolley ui

ScanFlow SmartTrolley UI
The trolley interface should be designed specifically for a mounted Android touchscreen: large touch targets, clear product confirmation, minimal typing, and a persistent connection indicator.

Main screens
NRF 2024 Retail's Big Show 参加レポート - ZOZO TECH BLOG
1. Home / Ready to shop

Start Scanning button.

Wi-Fi connection and battery status.

Basket count and Help shortcut.

変わり始めた地方の小売。TRIALスマートストアで買い物【小寺信良のシティ・カントリー・シティ】-Impress Watch
2. Product scanning

Live scanner feedback and torch.

Product name and server-confirmed price.

Clear confirmation before scanning another item.

Wakefern Rolls Out Latest Caper Carts in New York, New Jersey | Progressive Grocer
3. Basket

Product list and quantities.

Add, remove and correct item quantities.

Estimated total and Checkout button.

Till vs Paybill in Kenya: What’s the Difference? - Nexura Africa
4. Checkout and payment

Final item and tax breakdown.

M-Pesa, card or cashier payment options where enabled.

Clear pending, successful and failed states.

Would you let a smart trolley call the shots in your grocery shop? - ABC listen
5. Help and settings

Request staff assistance.

Test scanner and connection.

View battery, language and device information.

Essential behaviour
Keep Home, Basket and Help accessible throughout shopping.

Show a visible warning if the trolley loses its connection.

Do not allow checkout with an unverified or stale basket.

Show product confirmation after every successful scan, with a quick way to undo an accidental addition.

Calculate all prices and totals on the ScanFlow backend.

Show payment success only after the payment has been verified.

Return to the ready-to-shop screen only after the previous session has been securely closed.

The generated storyboard above is a visual concept. Its example products, amounts and transaction references are illustrative, not live ScanFlow data.

give me ui designs for the whole app

ScanFlow — Complete App UI Design
The design above brings the entire ScanFlow ecosystem together under one consistent visual identity: deep green, white and charcoal, with clean layouts, clear product imagery and practical retail workflows.

The complete design covers five connected interfaces.

1. Customer mobile app
Smart Shopping APP UI/UX Design by Sajjad Hossain on Dribbble
Screens to design and implement:

Welcome, onboarding and sign-in.

Shop QR scanning and branch selection.

Product barcode scanner and manual product search.

Product details, quantities and basket management.

Promotions and coupon entry.

Checkout and payment method selection.

M-Pesa payment pending, success, failure and retry.

Digital receipts and order history.

Customer profile, loyalty points and notifications.

Help, accessibility and language settings.

2. SmartTrolley interface
Checkers SkipstySkipsty 🛒 What’s Inside The New Checkers Smart Trolley
Designed for a trolley-mounted touchscreen with large controls and minimal navigation.

Ready-to-shop home screen.

Barcode scanning and product confirmation.

Basket editing and estimated totals.

Checkout and payment selection.

Payment status and receipt.

Connection loss and recovery.

Battery, scanner and Wi-Fi diagnostics.

Staff assistance and session reset.

3. Admin dashboard
SupaPOS – Modern, Human-Centered POS Dashboard by Jahedul Islam on Dribbble
The owner and manager interface should include:

Sales overview and analytics.

Products, categories, barcodes and pricing.

Inventory, stock movements and supplier orders.

Branch and staff management.

Active orders and shopping sessions.

SmartTrolley fleet and device health.

Payments, refunds and reconciliation.

Customers, promotions and loyalty.

Reports, audit logs and business settings.

4. Cashier POS
Features - Payrillium
The POS should be optimized for speed, supporting barcode scanning, quick product search, quantity edits, cash and supported digital payments, receipt printing, suspended sales, returns and authorized refunds.

5. Shared design system
ScanFlow component library
Primary button

#163D32

Navigation

#252B29

Success
Pending
Error
Offline
Shared elements: product cards, price displays, quantity controls, tables, search bars, confirmation dialogs, status indicators, loading states and empty states.

How the screens should connect
Customer app / SmartTrolley / POS

Different interfaces, same retail platform

ScanFlow backend
Pricing · Inventory · Orders · Payments · Security

Admin dashboard and reporting

Live operational data, alerts and management

All interfaces should use the same product catalogue, server-calculated prices and inventory records. Payment screens must show success only after payment verification.

Recommended implementation order: build the shared design system first, followed by the customer scanning and basket screens, the cashier POS, the admin dashboard, and finally the SmartTrolley interface. This establishes the core shopping experience before adding hardware-specific controls.

now prompt for the whole system
Below is a comprehensive master prompt you can paste into an AI coding platform such as Cursor, Claude Code, Replit, Bolt or another coding agent to build ScanFlow by TRIXX Technologies.

It covers the entire product: customer mobile app, SmartTrolley, cashier POS, business administration, inventory, payments, security, analytics, backend, database and deployment.

The prompt explicitly requires a working, integrated system, not just attractive screens or a clickable mockup.

MASTER AI DEVELOPMENT PROMPT — SCANFLOW BY TRIXX TECHNOLOGIES
1. Project identity and mission
You are a senior software architect, full-stack development team, UI/UX designer, cybersecurity engineer, database engineer, payment integration specialist and IoT engineer.

Your task is to design, develop, test and document ScanFlow, a production-oriented retail scanning, smart shopping, point-of-sale and store management platform owned by TRIXX Technologies.

Brand name: ScanFlow
Parent company: TRIXX Technologies
Tagline: Scan. Shop. Go.
Primary market: Kenya, with an architecture that supports international expansion.
Product category: Retail technology, smart shopping, POS, inventory management and retail analytics.

Build a complete, integrated software system with a consistent design language, secure backend, functional database, reliable transaction processing and documented hardware integration.

Do not deliver only a landing page, frontend mockup, design prototype, static dashboard or collection of disconnected modules. Every major interface must connect to real backend functionality.

If the implementation environment cannot complete the entire system in one pass, build it incrementally in the order specified below, keeping the project runnable after each phase.

2. Core product concept
ScanFlow allows customers to shop through three integrated methods:

Phone scanning: Customers use their smartphones to scan product barcodes in supermarkets, minimarkets, groceries and small retail shops.

SmartTrolley: Customers use a shopping trolley fitted with a barcode scanner, Android touchscreen and Wi-Fi-connected controller.

Cashier POS: Staff scan products using a conventional barcode scanner and complete transactions at a checkout counter.

All three shopping methods must share one backend, product catalogue, pricing engine, inventory ledger, order system and payment-processing workflow.

The platform must support small independent shops, medium-sized retailers, supermarkets and multi-branch retail chains.

Retailers must be able to enable or disable supported shopping methods by branch. A small shop must be able to operate without SmartTrolley hardware.

3. Mandatory technology stack
Use the following technologies unless a genuine technical limitation prevents implementation.

Frontend
Flutter and Dart for customer mobile applications.

Flutter Web for the business administration dashboard and cashier POS where appropriate.

Flutter-compatible Android interfaces for the SmartTrolley touchscreen.

Responsive layouts for desktop, tablet and mobile.

Reusable widgets, design tokens, themes, form components and navigation structures.

Typed API models, centralized API clients, state management and proper error handling.

Camera and barcode-scanning packages compatible with the target platforms.

Secure local storage for appropriate authentication and session data.

Choose and document a maintainable state-management approach, such as Riverpod or Bloc. Do not mix multiple state-management systems without a clear reason.

Backend
Java with Spring Boot.

Spring Security for authentication and authorization.

Spring Data JPA and Hibernate where appropriate.

PostgreSQL as the primary database.

Flyway for database migrations.

Bean Validation for request validation.

OpenAPI for API documentation.

Transactional outbox and durable background processing for critical asynchronous workflows.

Redis only where caching, rate limiting or distributed coordination genuinely requires it.

Docker and Docker Compose for local development.

Automated tests and a CI pipeline.

Integrations
Design adapter interfaces for:

M-Pesa and other supported payment providers.

Email, SMS and push notifications.

Receipt printers.

Barcode scanners.

SmartTrolley controllers.

Optional external accounting, supplier and retail systems.

Do not hardcode provider credentials, invent live payment integrations or assume that a provider account is already approved.

4. Required applications and interfaces
Build the following connected interfaces.

A. Customer mobile application
Implement these screens:

Splash screen and ScanFlow branding.

Welcome and onboarding.

Registration and sign-in.

Guest shopping where permitted by the branch.

Shop QR scanner.

Branch selection and confirmation.

Product barcode scanner.

Manual barcode entry.

Product search and product details.

Shopping basket.

Quantity changes and item removal.

Promotions and coupon application.

Checkout and final order summary.

Payment method selection.

M-Pesa payment initiation and pending state.

Payment success and failure states.

Retry and payment-status recovery.

Digital receipts.

Order history.

Customer profile.

Loyalty points and rewards.

Notifications.

Help and support.

Language and accessibility settings.

Privacy and account settings.

The scanner should open quickly, provide clear scan feedback and prevent accidental duplicate scans.

After scanning a product, display its server-confirmed name, image, price and relevant information.

Keep the basket accessible from the primary shopping screens.

Allow customers to recover a valid shopping session after a temporary interruption, subject to session expiry and security rules.

B. SmartTrolley touchscreen application
Build a dedicated interface optimized for an Android tablet mounted on a shopping trolley.

Required screens:

Ready-to-shop home screen.

Device connection and battery status.

Customer session initiation.

Barcode scanning.

Product successfully added.

Unknown barcode and scan error.

Basket and quantity controls.

Estimated basket total.

Checkout review.

Payment selection.

Payment pending.

Payment successful.

Payment failed or uncertain.

Receipt access.

Connection lost.

Automatic reconnecting state.

Stale basket warning.

Staff assistance.

Scanner diagnostics.

Wi-Fi and device health.

Language settings.

Session completion and secure reset.

Use large touch targets, readable text, strong contrast and minimal navigation.

Keep Home, Basket and Help easily accessible.

Never permit checkout using an unverified basket or present an unconfirmed payment as successful.

When the session ends, clear customer-specific information and return the trolley to a secure ready state.

C. Cashier POS application
Implement:

Staff sign-in.

Branch and terminal selection.

Till opening and closing.

Cashier shift management.

Barcode scanning.

Product search.

Frequently sold product shortcuts.

Itemized shopping cart.

Quantity adjustments.

Price and promotion validation.

Cash payment.

Supported digital payment methods.

Cash received and change due.

Suspended sales and sale recovery.

Receipt printing and digital receipts.

Returns and exchanges.

Refund requests and approvals.

Discounts subject to permissions.

Voids and cancellations.

Customer identification when appropriate.

Till reconciliation.

Cashier performance summaries.

Offline connection warnings.

Transaction audit history.

Optimize the POS for speed, keyboard navigation and barcode scanner use.

D. Retailer admin dashboard
Create a professional desktop-first management interface with responsive tablet support.

Navigation sections:

Overview.

Business profile.

Branches.

Products and categories.

Barcode management.

Pricing and tax settings.

Promotions.

Inventory.

Suppliers.

Purchase orders.

Goods receiving.

Stock transfers.

Stock counts and adjustments.

Orders and shopping sessions.

Cashier operations.

SmartTrolleys and devices.

Payments and finance.

Refunds and reconciliation.

Customers.

Loyalty and rewards.

Staff and permissions.

Reports and analytics.

Notifications.

Security and audit.

Integrations.

Subscription and billing.

Business settings.

The dashboard overview must show:

Today's sales.

Completed orders.

Average order value.

Sales by branch.

Sales by shopping channel.

Low-stock products.

Out-of-stock products.

Pending payments.

Refund exceptions.

Active shopping sessions.

Trolley connectivity.

Top-selling products.

Recent transactions.

Important operational alerts.

Provide useful date filters, branch filters, search, pagination and authorized CSV exports.

All dashboard metrics must be based on real backend data rather than hardcoded demonstration values.

E. TRIXX platform super-admin dashboard
Build a separate platform-level administration area for TRIXX Technologies.

Features:

Retailer registration and account management.

Tenant onboarding.

Subscription plans and feature entitlements.

Usage monitoring.

Platform health monitoring.

Authorized support tools.

Integration configuration.

Tenant suspension and reactivation workflows.

Security alerts.

Audit records.

Background-job monitoring.

Device fleet statistics.

Service usage and operational reporting.

Enforce strict separation between platform administration and individual retailer administration.

Support access to customer data must be restricted, authorized, logged and limited to a legitimate support purpose.

5. Registration and onboarding workflows
Retail business onboarding
Implement this sequence:

Business owner creates an account.

Email or phone verification is completed as required.

Business profile is created.

Initial branch is created.

Branch currency, timezone and operating details are configured.

Products are added manually or imported from CSV.

Staff members are invited.

Staff roles and permissions are assigned.

Payment methods are configured.

Optional SmartTrolley devices are registered.

Branch shopping methods are selected.

Receipt, inventory and checkout policies are configured.

A test transaction is completed.

The business goes live.

Provide a setup checklist with clear progress indicators.

Allow businesses to begin with phone scanning and cashier POS without completing SmartTrolley setup.

Customer onboarding
Provide optional customer registration where guest shopping is permitted.

Do not force customers to create accounts unless the branch policy or a required feature makes authentication necessary.

Explain camera permissions and request them only when needed.

6. Product catalogue and barcode engine
Create a shared product catalogue.

Product fields should include:

Product ID.

SKU.

Product name.

Description.

Brand.

Category.

Images.

Barcode mappings.

Unit of measure.

Pack size.

Product variants.

Cost price with restricted access.

Standard retail price.

Branch-specific price.

Tax category.

Active status.

Supplier references.

Batch and expiry information where applicable.

Promotion eligibility.

Support:

Multiple barcodes where appropriate.

Barcode import and validation.

Duplicate detection.

Product search.

Branch-specific availability.

Weighted products.

Multipacks and bundles.

Product activation and archival.

Product image management.

Price history.

Barcode scanning workflow
The phone, SmartTrolley or cashier scanner reads a barcode.

The client submits the barcode and relevant session context.

The backend authenticates the user or device.

The backend validates the branch and shopping session.

The catalogue service resolves the barcode.

The pricing service retrieves the correct branch price.

Promotion and tax rules are evaluated.

Product availability is checked.

The basket is updated according to business rules.

The backend returns the confirmed result.

If a barcode is unknown or a product is unavailable, return a structured error and offer product search or staff assistance.

Never trust prices, tax amounts, discount amounts or basket totals supplied by a client.

7. Pricing, taxes and promotions
Implement a centralized pricing engine.

Support:

Standard prices.

Branch-specific prices.

Effective-dated price changes.

Configurable tax categories.

Applicable tax calculations.

Percentage discounts.

Fixed discounts.

Multi-buy offers.

Buy-one-get-one offers.

Coupon codes.

Member pricing.

Product and category promotions.

Promotion start and end dates.

Redemption limits.

Promotion stacking rules.

Authorized manual discounts.

The engine must return a transparent price breakdown.

At checkout, recalculate the entire basket on the server and apply a documented policy for price changes that occur during a shopping session.

Preserve the final item prices, tax breakdown, discounts and currency in the order snapshot.

Do not assume that one tax rate applies to all products. Tax rules must be configurable and reviewed against applicable Kenyan requirements.

8. Inventory and supplier management
Create an inventory ledger that records every stock movement.

Support:

Opening stock.

Goods received.

Purchase orders.

Partial deliveries.

Supplier returns.

Stock transfers.

Physical stock counts.

Approved adjustments.

Damaged stock.

Expired stock.

Customer returns.

Sales deductions.

Batch and expiry tracking.

Low-stock thresholds.

Reorder suggestions.

Stock valuation.

Inventory movement reports.

Maintain an efficient inventory balance for queries, backed by auditable movement records.

Use database transactions and appropriate concurrency controls to prevent overselling.

Define exactly when stock is reserved, released and deducted. Prevent duplicate deductions when a payment callback or order-processing job is retried.

Supplier module
Include:

Supplier profiles.

Supplier product mappings.

Purchase requisitions.

Approval workflows.

Purchase orders.

Expected delivery dates.

Goods received notes.

Delivery discrepancies.

Invoice matching.

Supplier performance reports.

Automatic purchasing must require explicit business configuration and authorization.

9. Shopping sessions and basket engine
Every shopping session must be associated with an authorized business, branch and shopping method.

Implement:

Session creation.

Session expiry.

Session recovery.

Device or customer association.

Basket creation.

Add and remove items.

Quantity updates.

Duplicate scan prevention.

Basket versioning.

Price refresh.

Stock validation.

Promotion recalculation.

Session cancellation.

Session completion.

Session locking during checkout.

Use unique event identifiers and idempotency controls to prevent duplicate scans from adding items twice.

Make concurrent basket updates safe.

Distinguish between a current, server-confirmed basket and a stale or locally cached basket.

10. Checkout and order management
Create a shared order service for all shopping channels.

At checkout:

Authenticate the customer, cashier or authorized device.

Validate the active session.

Retrieve the authoritative basket.

Revalidate products and branch availability.

Recalculate prices, taxes and discounts.

Validate quantities and stock policy.

Create an order using an idempotency key.

Record an immutable purchase-time item and pricing snapshot.

Create a payment attempt when payment is required.

Return the order reference and current status.

Use explicit order states, such as:

DRAFT.

PENDING_PAYMENT.

PAID.

COMPLETED.

PAYMENT_FAILED.

CANCELLED.

EXPIRED.

REFUND_PENDING.

PARTIALLY_REFUNDED.

REFUNDED.

Use a separate payment state machine. Do not treat order creation as proof of payment.

Make repeated checkout requests safe and prevent duplicate orders.

11. Payment integration and M-Pesa
Build a payment abstraction that supports M-Pesa and additional providers.

Implement:

Payment initiation.

Provider transaction references.

Pending status.

Confirmed payment status.

Failed payment status.

Timeout handling.

Provider callbacks.

Callback authentication and validation.

Duplicate callback prevention.

Transaction-status enquiries where supported.

Payment reconciliation.

Refund workflows.

Settlement reporting.

Provider error mapping.

Payment rules
The backend calculates the amount.

The backend creates the order and payment attempt.

The backend sends the payment request through the configured provider adapter.

The customer authorizes the transaction through the provider's approved channel.

ScanFlow waits for a verified provider outcome.

Payment records are updated idempotently.

The order-processing workflow completes only when its required payment conditions are met.

A receipt is issued according to the configured policy.

Inventory and reporting records are finalized reliably.

An accepted STK Push request does not prove that a payment succeeded.

Do not simulate a successful live payment in production.

When a payment times out, preserve the uncertain state and reconcile it before allowing a potentially duplicate charge.

Use provider sandbox credentials for testing and environment-based secrets for deployment.

12. Exit verification and loss prevention
Build an optional exit-verification workflow for self-scanning branches.

Features:

Short-lived exit passes.

Order-bound QR verification.

Server-side validation.

Single-use pass consumption.

Expiry handling.

Attendant authentication.

Risk-based or random basket checks.

Required full checks where configured.

Exception escalation.

Verification audit history.

Secure reissue when appropriate.

The backend must verify payment and order eligibility before authorizing exit.

A QR code or digital receipt alone must not be treated as proof that physical basket contents match the order.

13. SmartTrolley hardware integration
Support a prototype consisting of:

Android touchscreen.

Barcode scanner with a documented UART or USB interface.

ESP32-class controller where suitable.

Wi-Fi connectivity.

Protected battery and regulated power supply.

Optional buzzer, status LEDs and device sensors.

Create a documented hardware communication contract.

Use HTTPS REST initially. Introduce MQTT over TLS only if later requirements justify it.

Suggested endpoints:

POST /api/v1/devices/pairing/start

POST /api/v1/devices/pairing/complete

POST /api/v1/trolleys/claim

POST /api/v1/device-events/scans

POST /api/v1/devices/{deviceId}/heartbeat

GET /api/v1/devices/{deviceId}/health

GET /api/v1/shopping-sessions/{id}/basket

POST /api/v1/shopping-sessions/{id}/checkout

POST /api/v1/orders/{id}/payments/mpesa

GET /api/v1/orders/{id}/payment-status

POST /api/v1/exit/verify

Document request payloads, responses, error codes and authentication requirements.

Hardware security
Pair devices through an authorized staff workflow.

Use revocable device credentials.

Do not place permanent secrets in QR codes.

Do not expose Wi-Fi passwords in public codes.

Provide secure Wi-Fi provisioning.

Use TLS for communication.

Validate every device event.

Support credential rotation and revocation.

Restrict setup mode.

Log device pairing and replacement.

Provide approved software-update procedures.

Hardware price rule
The trolley controller, Android interface and scanner must never calculate product prices, taxes, discounts or final totals.

The controller collects scan input and sends events. The backend determines the authoritative basket.

Offline behaviour
Buffer eligible scan events locally with unique IDs and retry them safely after reconnection.

Display connection loss and stale-data warnings.

Do not allow checkout with an unverified basket.

Do not invent offline payment approval.

14. Business administration and branch settings
Implement configurable branch policies for:

Phone scanning.

SmartTrolley scanning.

Cashier POS.

Guest checkout.

Customer login requirements.

Enabled payment methods.

Exit verification.

Receipt delivery.

Promotion eligibility.

Stock reservation.

Negative-stock policy.

Offline operation.

Loyalty.

Notification preferences.

Allow parent-business defaults with branch-level overrides where permitted.

Enforce configuration rules on the backend. Hiding a frontend button is not sufficient authorization.

15. Customer loyalty and promotions
Implement optional loyalty features:

Loyalty account.

Points earning.

Points redemption.

Member pricing.

Coupons and rewards.

Tiered membership.

Expiry policies.

Refund-related points reversal.

Loyalty ledger.

Reward usage limits.

Loyalty analytics.

Only award points for eligible completed transactions.

Use a ledger for loyalty changes rather than directly overwriting balances without an audit trail.

16. Reports and analytics
Build reporting APIs and interfaces for:

Sales by day, hour and branch.

Sales by product and category.

Sales by shopping channel.

Completed orders.

Average basket value.

Gross sales and discounts.

Taxes and refunds.

Estimated gross margin.

Payment methods.

Payment reconciliation.

Inventory valuation.

Stock turnover.

Stockout frequency.

Expiry and wastage.

Supplier performance.

Customer retention.

Loyalty usage.

Cashier performance.

Shopping session abandonment.

Scan errors.

Trolley uptime.

Device connectivity.

Checkout duration.

Provide date filters, branch filters, pagination and authorized exports.

Clearly define how each financial metric is calculated. Do not present incomplete cost data as a reliable profit figure.

Advanced analytics can later provide demand forecasting, stock recommendations and unusual-transaction alerts.

17. User roles and permissions
Implement backend-enforced role-based access control.

Required roles:

Platform super administrator.

Business owner.

Branch manager.

Inventory officer.

Cashier.

Finance officer.

Exit verification attendant.

Auditor.

Supplier.

Customer.

Device support technician.

Allow permissions to be scoped to a business and branch.

Require appropriate approvals for sensitive operations such as refunds, price overrides, stock adjustments, staff privilege changes and device pairing.

Maintain audit logs for privileged actions.

Prevent users from accessing another tenant's records through manipulated IDs, API requests or query parameters.

18. Database architecture
Use PostgreSQL with Flyway migrations.

Create a normalized schema with appropriate foreign keys, indexes, constraints and transaction boundaries.

Include tables or equivalent entities for:

Businesses.

Branches.

Users.

Memberships.

Roles and permissions.

Devices and device credentials.

Products and categories.

Product barcodes.

Branch products.

Price lists and product prices.

Tax categories.

Promotions and promotion rules.

Inventory balances.

Inventory movements.

Suppliers.

Purchase orders.

Goods received notes.

Shopping sessions.

Scan events.

Baskets and basket items.

Orders and order items.

Payments and payment attempts.

Provider webhook events.

Refunds.

Receipts.

Exit passes and exit verifications.

Customer profiles.

Loyalty accounts and ledger.

Notifications.

Audit logs.

Subscriptions and usage records.

Use UUIDs or another consistent identifier strategy.

Use decimal monetary types with explicit currency codes.

Preserve transaction snapshots.

Use unique constraints and idempotency keys for scan events, orders, payment callbacks and refund requests.

Keep sensitive data to a minimum.

Do not use destructive deletion for products or financial records that have historical references.

19. API architecture
Create a versioned REST API under /api/v1.

Organize controllers, services, repositories, DTOs, validation and error handling cleanly.

Document every endpoint in OpenAPI.

Use:

Consistent response structures.

Structured error codes.

Request validation.

Pagination and filtering.

Authorization checks.

Correlation IDs.

Idempotency keys for retryable financial operations.

Rate limiting.

Safe transaction boundaries.

Avoid exposing internal entity objects directly as API responses.

Generate and maintain API documentation that matches the actual implementation.

20. UI/UX design system
Use the following ScanFlow visual identity.

Primary green: #163D32
Charcoal: #252B29
Page background: #F5F7F5
White: #FFFFFF
Success surface: #E5F3EB
Warning surface: #FFF0D8

Use Inter or Roboto typography.

Design principles:

Clean, premium retail technology aesthetic.

Consistent spacing and alignment.

Rounded cards and subtle borders.

Clear typography and strong contrast.

Restrained use of shadows.

Product imagery that supports shopping.

Consistent iconography.

Accessible controls and forms.

Responsive layouts.

Clear loading, empty, success, error and retry states.

Avoid excessive gradients, decorative animations and generic AI-generated dashboard styling.

Use shared design tokens and reusable components across the customer app, SmartTrolley, POS and admin dashboard.

Make the interface look like a real production retail product rather than a template.

21. Security, privacy and compliance
Implement:

HTTPS.

Secure password hashing.

Secure account recovery.

Short-lived access tokens.

Appropriate refresh-token controls.

Role-based authorization.

Tenant isolation.

Device authentication.

Rate limiting.

Input validation.

SQL injection prevention.

Cross-site scripting protection where relevant.

Secure CORS configuration.

Webhook signature or authenticity validation according to provider documentation.

Idempotent financial processing.

Secrets management.

Audit logging.

Encrypted backups.

Dependency vulnerability scanning.

Controlled data retention.

Account and data access procedures.

Security incident logging.

Never store payment PINs or card security codes.

Do not log passwords, access tokens, payment secrets or unnecessary personal data.

Design the platform for applicable Kenyan data protection and tax requirements, including the Data Protection Act, 2019, and relevant guidance. Confirm legal and provider-specific requirements before live deployment.

Do not claim legal or regulatory certification without evidence.

22. Error handling and reliability
Design explicit behaviour for:

Unknown barcode.

Duplicate scan.

Expired session.

Product deactivation.

Price change.

Out-of-stock product.

Network disconnection.

Stale basket.

Duplicate checkout request.

Payment timeout.

Payment failure.

Delayed provider callback.

Duplicate callback.

Refund timeout.

Trolley disconnection.

Scanner failure.

Device credential revocation.

Database outage.

Background worker failure.

Use retry with backoff for transient failures.

Use durable processing for important asynchronous work.

Do not blindly repeat payment requests when the original outcome is uncertain.

Provide operational logs, metrics, health endpoints and actionable alerts.

23. Notifications
Implement a notification system supporting in-app notifications and optional email, SMS or push providers.

Examples:

Low stock.

Pending delivery.

Payment confirmed.

Payment reconciliation exception.

Refund status.

Device offline.

Low trolley battery.

Scanner failure.

Suspicious operational activity.

New staff invitation.

Subscription status.

Deduplicate repetitive alerts and allow severity settings.

Notifications must not be the authoritative record of financial outcomes.

24. Subscription and billing
Design ScanFlow as a multi-tenant SaaS platform.

Support configurable plans:

Starter

Phone scanning.

Basic POS.

Product catalogue.

Inventory.

Basic reporting.

Business

Advanced inventory.

Promotions and loyalty.

Staff management.

Extended analytics.

Optional SmartTrolley integration.

Enterprise

Multiple branches.

Advanced permissions.

Centralized policies.

Device fleet management.

Supplier workflows.

Advanced reporting and integrations.

These are proposed plan capabilities, not fixed commercial prices.

Implement subscription status, billing periods, entitlements, usage limits and controlled feature enforcement.

25. Testing requirements
Create automated tests at multiple levels.

Backend unit tests
Test pricing, promotions, tax calculations, stock movements, authorization and state transitions.

Backend integration tests
Test database transactions, repositories, APIs, concurrency and migrations.

Frontend tests
Test navigation, forms, basket updates, error states and API integration.

End-to-end tests
Test the complete shopping journey across supported channels.

Mandatory scenarios:

Phone scan to completed sale.

Cashier POS sale.

SmartTrolley scan and basket update.

Unknown barcode.

Repeated scan event.

Product becoming unavailable.

Price change before checkout.

Two customers attempting to purchase the final unit.

Successful M-Pesa payment.

Failed M-Pesa payment.

Delayed callback.

Duplicate callback.

Payment status uncertainty.

Refund approval.

Branch authorization failure.

Cross-tenant access attempt.

Trolley network loss and recovery.

Session expiry.

Exit-pass reuse.

Inventory reconciliation after a failure.

Backup restoration.

Report accuracy across multiple shopping channels.

Use mocked providers or approved sandbox environments for payment tests.

26. Deployment and DevOps
Provide:

A complete repository structure.

Backend Dockerfile.

Frontend build instructions.

Docker Compose for local development.

PostgreSQL service configuration.

Flyway migrations.

Environment-variable examples.

Health checks.

Structured logging.

CI pipeline.

Automated test execution.

Deployment documentation.

Database backup and restore instructions.

Production environment configuration guidance.

A secure secrets-management strategy.

Do not put production credentials in source code.

Ensure the project starts using the documented commands and that migrations run predictably.

27. Required project structure
Organize the repository clearly. A suggested structure is:

scanflow/

apps/customer_app/

apps/admin_web/

apps/pos_app/

apps/smart_trolley/

backend/

backend/src/main/java/

backend/src/main/resources/db/migration/

backend/src/test/

hardware/controller_firmware/

hardware/protocol/

docs/

infra/docker/

infra/ci/

.env.example

docker-compose.yml

README.md

Adapt this structure when the chosen Flutter workspace or build system requires it, but maintain clear boundaries between applications, backend modules, hardware firmware and documentation.

28. Required deliverables
Produce the following deliverables:

Architecture overview and component diagram.

Database ERD and migration files.

Backend source code.

Flutter customer application.

Flutter admin dashboard.

Cashier POS application.

SmartTrolley touchscreen application.

SmartTrolley communication contract and controller example.

API specification.

Authentication and permissions model.

Payment integration adapters.

Automated tests.

Docker configuration.

CI configuration.

.env.example without real secrets.

Installation and setup instructions.

Deployment guide.

Troubleshooting guide.

Security and privacy checklist.

Test data or seed data for local development.

Sample user accounts for local development only, with clearly documented credentials and no production privileges.

Known limitations and outstanding tasks.

Where a real external integration cannot be completed without credentials or approved provider access, implement the adapter contract, sandbox configuration and clearly labeled development mock. Do not falsely claim that a real transaction or hardware connection has been tested.

29. Development execution order
Work through these phases in order.

Phase 1 — Foundation
Create the repository, backend, database, migrations, authentication, business registration, branch management, permissions and design system.

Phase 2 — Catalogue and POS
Implement products, barcodes, branch pricing, inventory ledger, cashier checkout, orders and receipts.

Phase 3 — Customer shopping
Implement shop QR entry, shopping sessions, phone scanning, shared baskets, product search and checkout validation.

Phase 4 — Payments
Implement the payment abstraction, M-Pesa sandbox integration, callbacks, reconciliation, failure recovery and refunds.

Phase 5 — Admin operations
Implement the management dashboard, stock management, staff management, reporting, promotions and branch configuration.

Phase 6 — SmartTrolley
Implement device registration, pairing, controller protocol, scanner input, touchscreen interface, health monitoring and safe reconnection.

Phase 7 — Advanced features
Implement loyalty, suppliers, purchasing, subscriptions, fleet management and advanced analytics.

Phase 8 — Production readiness
Complete automated tests, security reviews, observability, backup recovery, deployment configuration and documentation.

At the end of every phase:

Run the relevant tests.

Fix failures before continuing.

Verify database migrations.

Verify the affected interfaces against the backend.

Update documentation.

Keep the repository in a runnable state.

Do not leave core modules as empty placeholders while claiming completion.

30. Definition of done
The project is complete only when:

The documented applications can be built.

The backend starts successfully.

Database migrations execute successfully.

Authentication and permissions work.

Tenant and branch isolation is enforced.

Products can be created and scanned.

Phone scanning and cashier sales use the same catalogue and inventory.

SmartTrolley events use the documented backend protocol.

Basket prices are calculated by the server.

Checkout produces a valid order.

Payment status is verified through the configured integration.

Duplicate requests do not create duplicate orders or payment effects.

Inventory updates are auditable.

Receipts are generated correctly.

Admin reports use actual database records.

Error and recovery states work.

Automated tests pass.

Setup and deployment instructions are complete.

All incomplete integrations are explicitly disclosed.

31. Instructions to the AI coding agent
Before coding, inspect the development environment and identify its supported tools, frameworks and deployment capabilities.

Then:

Present a concise architecture and implementation plan.

Establish the repository structure.

Implement the first runnable vertical slice.

Run it and test it.

Continue through the development phases.

Report files created, commands executed, test results and unresolved issues.

Never report a successful build, test, payment or device connection unless it was actually verified.

Ask a clarification only when an essential decision cannot reasonably be handled through a documented, configurable default.

Prefer complete, maintainable implementations over superficial feature lists.

Keep business rules in the backend and keep interfaces responsible for presentation and user interaction.

Final objective: deliver ScanFlow as a coherent, secure and extensible retail platform that can begin with a small Kenyan shop using phone scanning and a cashier POS, then grow into a multi-branch supermarket network using SmartTrolleys, advanced inventory, payment integrations and business analytics—all without rebuilding the core system.

Build the real product, not just the appearance of the product.

How to use this prompt
Paste the prompt into your AI coding agent.

Ask it to begin with Phase 1 and a runnable project, not to generate every module as untested code in one response.

Have it run the backend, database migrations and tests before moving to the next phase.

Configure real M-Pesa credentials and physical SmartTrolley hardware only when those integrations are ready.

Keep the repository under version control so you can review and recover changes.

My recommendation: get the catalogue, inventory, cashier POS and phone-scanning checkout working first. Those features establish the foundation for the trolley hardware and the rest of ScanFlow.

