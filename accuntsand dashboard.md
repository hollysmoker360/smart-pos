ScanFlow — Account Types & Dashboard Features
ScanFlow by TRIXX Technologies should use a role-based account system in which each user gets a dashboard tailored to their responsibilities. A supermarket owner should see business performance, a cashier should see checkout tools, a customer should see shopping features, and TRIXX platform administrators should manage the ScanFlow platform itself.

The system should also support multiple branches, with permissions limited to the relevant business and branch.
1. Complete account structure
TRIXX Technologies
ScanFlow platform administration


Retail business / supermarket chain
Business owner and authorized managers


Branch staff

Managers, cashiers, inventory, finance and attendants


Customers

Phone scanning, trolley shopping, payments and receipts


Suppliers

Purchase orders, deliveries and invoices


Registered devices

SmartTrolleys, POS terminals and hardware health




2. Account types and their dashboards
Account 1 — TRIXX Super Administrator









Platform level
Purpose: Manage ScanFlow as a product offered to multiple retailers.

Dashboard features:
- Total registered businesses and active branches.
- New business registrations and onboarding approvals.
- Subscription plans, billing and feature entitlements.
- Platform uptime, errors and service health.
- Payment integration health and background-job failures.
- SmartTrolley fleet statistics across tenants.
- Support tickets and authorized support access.
- Security alerts, audit logs and incident management.
- Platform configuration and feature rollout.


Permissions: Manage the platform, not unrestricted access to every retailer's private records. Sensitive support access must be authorized and audited.
Account 2 — TRIXX Support Administrator
Purpose: Help retailers troubleshoot ScanFlow.

Dashboard features:
- Search for businesses, branches and registered devices.
- View device connectivity and diagnostic logs.
- Investigate API and integration errors.
- Manage support tickets and escalation.
- Guide account recovery.
- Review authorized diagnostic information.
- Track resolution time and recurring issues.
Restrictions: No automatic permission to edit financial records, issue refunds, view payment secrets or change retailer stock.
Account 3 — Business Owner









Purpose: Own and control a retail business using ScanFlow.

Dashboard features:
- Total sales and order counts.
- Sales by branch and shopping method.
- Revenue trends and product performance.
- Inventory overview and low-stock alerts.
- Cashier and staff management.
- Branch creation and settings.
- Payment reconciliation and refund oversight.
- Supplier management and purchase approvals.
- Subscription and billing.
- Business-wide reports and audit history.


Permissions: Full business-level administration, subject to security controls. The owner can assign roles but cannot access another business's tenant data.
Account 4 — Business Administrator
Purpose: Handle day-to-day business configuration on behalf of the owner.

Dashboard features:
- Manage products, categories and barcodes.
- Configure branch pricing and promotions.
- Create and manage staff accounts.
- Configure shopping methods.
- View orders and inventory.
- Manage suppliers and purchase orders.
- View operational reports.
- Configure receipts and notifications.
Restrictions: Financial approvals, subscription ownership and sensitive settings can be reserved for the owner.
Account 5 — Branch Manager









Purpose: Manage one or more authorized branches.

Dashboard features:
- Branch sales and daily targets.
- Active orders and shopping sessions.
- Cashier shift monitoring.
- Stock availability and replenishment.
- Goods receiving and stock transfers.
- Trolley availability and device alerts.
- Staff schedules and operational tasks.
- Returns and refund requests.
- Branch-specific performance reports.


Permissions: Access only assigned branches. Refund approval and price overrides depend on assigned permissions.
Account 6 — Cashier









Purpose: Process conventional counter sales.

Dashboard features:
- Open and close assigned till.
- Scan product barcodes.
- Search for products.
- Add, remove and change quantities.
- Process authorized discounts.
- Accept enabled payment methods.
- Print or send receipts.
- Suspend and resume sales.
- Request returns or refunds.
- View own shift totals and transaction history.


Restrictions: No unrestricted access to business profits, supplier costs, other cashiers' private records or system configuration.
Account 7 — Inventory Officer
Purpose: Maintain accurate stock records.

Dashboard features:
- Product and barcode lookup.
- Current stock by branch.
- Goods received and delivery discrepancies.
- Purchase orders and supplier deliveries.
- Stock transfers.
- Physical stock counts.
- Damaged, expired and returned goods.
- Batch and expiry tracking.
- Low-stock alerts.
- Reorder suggestions.
- Inventory movement history.
Restrictions: Stock adjustments should require a reason and be audited. High-value adjustments can require manager approval.
Account 8 — Finance Officer / Accountant
Purpose: Monitor and reconcile financial activity.

Dashboard features:
- Sales and payment summaries.
- M-Pesa and other provider reconciliation.
- Cash and digital payment breakdown.
- Refunds and charge exceptions.
- Settlement tracking.
- Tax reports and transaction exports.
- Till closing and cash variance reports.
- Revenue and discount summaries.
- Supplier invoice records.
- Audit-ready financial history.
Restrictions: Viewing financial data does not automatically authorize changing prices, editing historical sales or approving one's own refunds.
Account 9 — Exit Verification Attendant
Purpose: Verify eligible self-scanning purchases at store exits.

Dashboard features:
- Scan the customer's exit QR code.
- Verify order and payment status.
- See the permitted verification result.
- Perform required or randomized basket checks.
- Record discrepancies.
- Escalate suspected mismatches.
- Request supervisor assistance.
- View recent verifications for the assigned branch.
Restrictions: Cannot mark unpaid orders as paid, edit the basket after checkout or issue refunds.
Account 10 — Supplier









Purpose: Work with retail businesses through a controlled supplier portal.

Dashboard features:
- View purchase orders shared with the supplier.
- Confirm or reject order quantities.
- Update delivery estimates.
- Submit delivery notes and invoices.
- View delivery history.
- Track invoice status where enabled.
- Maintain supplier product information.
- Communicate with the authorized purchasing team.


Restrictions: A supplier can access only the information shared with that supplier by the relevant retailer.
Account 11 — Customer









Purpose: Shop using a phone or supported SmartTrolley.

Dashboard features:
- Scan a store QR code.
- Scan products and search the catalogue.
- View and edit the basket before checkout.
- See applicable promotions.
- Pay using enabled payment methods.
- View receipts and purchase history.
- Track loyalty points and rewards.
- Manage preferences and notifications.
- Request support.
- Manage account and privacy settings.


Restrictions: Customers see their own account, shopping sessions and permitted purchase records only.
Account 12 — SmartTrolley / Registered Device
This is a device identity, not a human user account. It should authenticate through its own device credentials.

Dashboard and device-console features:
- Device ID and assigned branch.
- Pairing and activation status.
- Online/offline status.
- Battery and scanner health.
- Last heartbeat and software version.
- Active session status.
- Scan-event delivery status.
- Connection and diagnostic logs.
- Credential revocation.
- Maintenance and replacement history.
A device must not receive general administrator privileges. It may submit authorized events and access only the data required for its active session.
Account 13 — Auditor / Read-only Reviewer
Purpose: Review activity without changing business records.

Dashboard features:
- Read-only transaction history.
- Stock movement and adjustment records.
- Payment reconciliation reports.
- Refund and approval trails.
- User activity and audit logs.
- Authorized report exports.
- Filtered records by assigned business and branch.
Restrictions: No editing products, stock, payments, staff permissions or historical transactions.

3. Interactive account and permissions planner
Use this planner to select an account type and see its proposed dashboard modules.
Select an account type
Business Owner

Business Owner
Access scope: All authorized business branches
Business overview

Sales and analytics

Branches

Staff and roles

Products and inventory

Payments and refunds

Suppliers and purchasing

Subscription and settings

Expand this dashboard into a full specification
4. Shared dashboard layout
Every human account dashboard should follow a consistent layout, while displaying only the modules the user is authorized to access.

ScanFlow
Retail operations



OVERVIEW
Sales today
KES —


Orders
—


Stock alerts
—


Devices online
—



Wireframe preview only. Dashes indicate that live data must come from the backend; widgets should vary by role.

Navigation behaviour
- Desktop: collapsible left sidebar and top utility bar.
- Mobile: bottom navigation for primary tasks, with secondary actions in a menu.
- SmartTrolley: dedicated touch interface rather than the admin layout.
- POS: transaction-first interface with minimal navigation during an active sale.
5. Important permission rules
Action	Default authorization
Create business and manage all its branches	Business owner
Manage platform-wide tenants	TRIXX super admin
Create and edit products	Owner, authorized admin or inventory role as configured
Change branch prices	Authorized owner/admin; manager if granted
Complete normal sales	Cashier
Approve large refunds	Owner or designated approver
Adjust stock	Authorized inventory staff; approval may be required
Reconcile payments	Finance officer or authorized owner
Verify an exit pass	Assigned exit attendant
Access supplier purchase orders	Supplier and authorized purchasing staff
View own shopping history	Customer
Submit scan events	Authorized registered device
Read audit records	Authorized auditor or administrator
Every permission must be checked by the backend. Frontend navigation alone must never enforce access control.
6. Recommended account creation and invitation flow
1. A retailer registers a business and becomes its initial owner.
2. The owner creates branches and configures business policies.
3. The owner or authorized administrator invites staff.
4. The inviter selects a role, branch scope and additional permissions.
5. The invited person verifies their account and accepts the invitation.
6. ScanFlow checks permissions on every protected API request.
7. The business can suspend the account, revoke sessions or change branch assignments.
8. All sensitive permission changes are recorded in the audit log.
Customers should register separately or use permitted guest shopping. Suppliers should be invited by a retailer or onboarded through an approved supplier process. SmartTrolleys must be registered and paired through a staff-controlled device enrollment flow.

Final recommendation: start with eight essential human roles—TRIXX Super Admin, Business Owner, Business Admin, Branch Manager, Cashier, Inventory Officer, Customer and Finance Officer. Add the supplier, exit attendant, support and auditor roles as their modules are implemented. Treat SmartTrolley as a separately authenticated device identity, not a human account.