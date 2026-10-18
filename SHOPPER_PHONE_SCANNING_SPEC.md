# TRIXX Shopper Phone Scanning Mode - Technical & Implementation Specification

## Executive Summary
This specification defines the architecture, data models, workflows, security controls, and admin capabilities required to introduce **Shopper Phone Scanning Mode** to the TRIXX retail checkout platform.

By enabling phone-based barcode scanning via customer smartphones (via native app or Progressive Web App), TRIXX becomes accessible and affordable for kiosks, minimarkets, convenience stores, and small supermarkets in Kenya without requiring capital expenditures on smart trolleys, external barcode hardware, or dedicated customer touchscreens.

---

## 1. Admin Store Settings & Configuration

Each store branch administrator can independently configure allowed checkout and scanning methods. Changes in the configuration screen present a live preview before being saved.

### 1.1 Admin UI Layout & Structure

```
================================================================================
TRIXX Store Settings
Checkout & customer scanning

[ Admin ]

Allowed scanning methods
  [x] Scan using customer's phone
      Use the camera to scan product barcodes in the TRIXX mobile app or supported web app.

  [ ] SmartTrolley scanning
      Use the trolley's embedded scanner and touchscreen.

  [ ] Manual barcode entry
      Allow entry of a barcode when the camera cannot read it.

Checkout controls
  [x] Require staff verification before exit
  [ ] Require customers to sign in before starting a shopping session

Preview configuration
  Phone scanning: Enabled
  SmartTrolley: Disabled
  Manual entry: Disabled
  Staff verification: Required
  Customer sign-in: Optional

Note: This is a configuration preview; it does not change a live store's settings.

[ Generate implementation specification ]  [ Save Configuration ]
================================================================================
```

### 1.2 Configuration Rules & Preview Logic Matrix

| Setting Variable | Selection State | Preview Output |
| :--- | :--- | :--- |
| `phoneScanningEnabled` | `true` / `false` | `Phone scanning: Enabled` / `Disabled` |
| `smartTrolleyEnabled` | `true` / `false` | `SmartTrolley: Enabled` / `Disabled` |
| `manualEntryEnabled` | `true` / `false` | `Manual entry: Enabled` / `Disabled` |
| `requireStaffVerification` | `true` / `false` | `Staff verification: Required` / `Optional` |
| `requireCustomerSignIn` | `true` / `false` | `Customer sign-in: Required` / `Optional` |

*Validation Rule:* At least one scanning method (`phoneScanningEnabled`, `smartTrolleyEnabled`, or manual cashier fallback) must be enabled per store branch.

### 1.3 Data Model & JSON Schema

#### Store Scanning Settings DTO (Java / JSON)
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "StoreScanningSettings",
  "type": "object",
  "properties": {
    "storeId": { "type": "string", "format": "uuid" },
    "branchCode": { "type": "string" },
    "allowedScanningMethods": {
      "type": "object",
      "properties": {
        "phoneScanningEnabled": { "type": "boolean" },
        "smartTrolleyEnabled": { "type": "boolean" },
        "manualBarcodeEntryEnabled": { "type": "boolean" }
      },
      "required": ["phoneScanningEnabled", "smartTrolleyEnabled", "manualBarcodeEntryEnabled"]
    },
    "checkoutControls": {
      "type": "object",
      "properties": {
        "requireStaffExitVerification": { "type": "boolean" },
        "requireCustomerSignIn": { "type": "boolean" },
        "allowGuestCheckout": { "type": "boolean" },
        "exitPassValidityMinutes": { "type": "integer", "default": 15 }
      },
      "required": ["requireStaffExitVerification", "requireCustomerSignIn", "allowGuestCheckout"]
    },
    "updatedAt": { "type": "string", "format": "date-time" },
    "updatedBy": { "type": "string" }
  },
  "required": ["storeId", "branchCode", "allowedScanningMethods", "checkoutControls"]
}
```

---

## 2. Phone Scanning End-to-End Workflow

```
[1. Join Shop] -----> [2. Scan Products] -----> [3. Review Basket] -----> [4. Pay via M-Pesa] -----> [5. Receipt & Exit Pass]
  QR / Deep Link        Camera Barcode          Server Total Check        Trusted Callback         QR Pass for Staff
```

### Step 1: Join the Shop
1. Customer scans a physical QR code posted at the shop entrance (e.g., `https://trixx.co.ke/s/NRB-042`) or opens a deep link.
2. The app/PWA parses the store branch (`NRB-042`) and invokes `POST /api/v1/sessions/start`.
3. If guest checkout is enabled, a temporary guest session token is generated without requiring account creation.
4. Response returns branch details, active pricing tier, currency (`KES`), and feature flags (e.g., manual entry allowed, exit verification required).

### Step 2: Scan Products
1. The device camera captures product barcode (EAN-13, UPC-A, QR, Code128).
2. The app submits barcode and session token to `POST /api/v1/cart/items/scan`.
3. The Java backend validates:
   - Barcode existence in branch catalog.
   - Active branch price and promotion rules.
   - Stock availability.
4. Product details (Name, Unit Price, Applied Discounts, Currency) are returned and added to cart state.

### Step 3: Review the Basket
1. Client displays itemized list, applied promotions (e.g., "Buy 2 Get 10 KES Off"), taxes (VAT), and server-computed total.
2. Customer updates quantities or removes items via `PATCH /api/v1/cart/items/{itemId}`.
3. Server re-calculates all subtotals, tax, and promotions to guarantee mathematical and promotional integrity.

### Step 4: Pay and Verify (M-Pesa Integration)
1. Customer clicks "Pay with M-Pesa" and supplies phone number.
2. App calls `POST /api/v1/checkout/pay` with `paymentMethod: "MPESA_EXPRESS"`.
3. Server triggers M-Pesa Daraja STK Push (`LipanampesaOnline`).
4. Backend listens for asynchronous payment callback from M-Pesa provider.
5. Order state remains `PAYMENT_PENDING` until trusted provider verification callback updates status to `PAID`.

### Step 5: Receive Digital Receipt & Exit Pass
1. Upon payment confirmation (`PAID`), server generates:
   - Digital Tax Receipt (`orderId`, line items, M-Pesa transaction code `NLX89231K`).
   - Short-lived signed Exit Pass (Time-based HMAC QR code containing `orderId`, `timestamp`, `hash`).
2. Customer presents Exit Pass to shop staff if store settings require exit verification.
3. Staff scans Exit Pass using the TRIXX Staff Dashboard app to verify paid status and item count.

---

## 3. REST API Specification

### `POST /api/v1/sessions/start`
Starts a shopper session for a specific branch.

**Request:**
```json
{
  "branchCode": "NRB-042",
  "deviceInfo": {
    "platform": "PWA",
    "userAgent": "Mozilla/5.0..."
  },
  "customerToken": null
}
```

**Response (200 OK):**
```json
{
  "sessionId": "sess_89f1a23b-4c5d",
  "storeName": "Kibera QuickMart Branch 2",
  "currency": "KES",
  "allowGuestCheckout": true,
  "manualEntryAllowed": false,
  "requireStaffExitVerification": true,
  "expiresAt": "2026-10-18T23:59:59Z"
}
```

---

### `POST /api/v1/cart/items/scan`
Scans a barcode and adds item to cart.

**Request:**
```json
{
  "sessionId": "sess_89f1a23b-4c5d",
  "barcode": "6161100012345",
  "idempotencyKey": "scan_tx_99218123"
}
```

**Response (200 OK):**
```json
{
  "cart": {
    "cartId": "cart_7712",
    "items": [
      {
        "itemId": "item_101",
        "productName": "Ungu Flour 2kg",
        "barcode": "6161100012345",
        "quantity": 1,
        "unitPrice": 180.00,
        "totalPrice": 180.00,
        "ageRestricted": false,
        "soldByWeight": false
      }
    ],
    "subtotal": 180.00,
    "discountTotal": 0.00,
    "vatTotal": 28.80,
    "grandTotal": 180.00
  }
}
```

---

### `POST /api/v1/checkout/pay`
Initiates M-Pesa STK Push payment.

**Request:**
```json
{
  "sessionId": "sess_89f1a23b-4c5d",
  "cartId": "cart_7712",
  "phoneNumber": "254712345678",
  "paymentProvider": "MPESA_STK_PUSH"
}
```

**Response (200 OK):**
```json
{
  "orderId": "ORD-20261018-883",
  "checkoutRequestId": "ws_CO_181020262100_892112",
  "status": "PAYMENT_PENDING",
  "message": "STK Push sent to 254712345678. Enter PIN on phone."
}
```

---

### `GET /api/v1/receipts/{orderId}`
Fetches final paid receipt and short-lived exit pass.

**Response (200 OK):**
```json
{
  "orderId": "ORD-20261018-883",
  "mpesaReceiptNumber": "NLX89231K",
  "paidAmount": 180.00,
  "currency": "KES",
  "paidAt": "2026-10-18T21:05:12Z",
  "items": [
    { "name": "Ungu Flour 2kg", "qty": 1, "price": 180.00 }
  ],
  "exitPass": {
    "passCode": "EP-883-991A",
    "qrPayload": "TRIXX:PASS:ORD-20261018-883:1760822112:a8f9c12e",
    "expiresAt": "2026-10-18T21:20:12Z",
    "verified": false
  }
}
```

---

## 4. Small Shop Practicality & PWA Features

1. **Hardware-less Operation:** Works on any camera-enabled smartphone (Android 6+, iOS 12+).
2. **Guest Checkout:** Allows shoppers to immediately scan items without forced registration or passwords.
3. **Progressive Web App (PWA):**
   - Built with modern Web APIs (`BarcodeDetector` API with fallback to lightweight JS barcode scanner libraries e.g., `@zxing/library`).
   - Serves cached shell assets via Web Workers for rapid loading on 2G/3G networks in Kenya.
4. **Quick Shop QR Onboarding:** Entrance QR codes contain simple branch identifiers (`/s/BRANCH_CODE`) that route directly into the branch session.
5. **Low-Data & Low-Bandwidth Optimizations:**
   - JSON payloads restricted to essential fields.
   - Local caching of non-sensitive store catalog headers (brand name, branch currency).
   - No image transmission from phone camera to backend; image decoding happens locally on phone CPU.
6. **Simple Staff Dashboard:**
   - Web application accessible on staff low-cost smartphone/tablet.
   - Real-time stream of active store sessions, unpaid carts, completed orders, and exit pass validations.
7. **Manual Fallback Integration:**
   - If a barcode is damaged or unreadable by phone camera, cashier can use the store's existing traditional till or staff device to complete the scan or lookup.

---

## 5. Security Controls & Fraud Prevention

| Security / Fraud Risk | Technical Mitigation Control |
| :--- | :--- |
| **Physical Substitution / Unscanned Items** | **Exit Verification & Risk Spot Checks:** Configurable exit pass verification where staff scan customer Exit QR pass. High-risk sessions (large item count, high total value, high velocity) trigger mandatory item count spot checks. |
| **Discrepancy Logging** | Staff dashboard records any discrepancy found during spot checks into audit logs for loss prevention metrics. |
| **Price Tampering** | **Server-side Validation:** Prices sent by client are strictly ignored. All line totals, taxes, and discounts are computed authoritatively on Java backend. |
| **Duplicate Scan Requests** | **Idempotency Keys:** Client generates UUID idempotency keys per scan event to prevent network retries from double-adding items. |
| **Unconfirmed Payment Exploits** | **Trusted Payment Webhooks:** Orders are never marked `PAID` until M-Pesa official callback payload with verified signature is received by backend. |
| **Age-Restricted / Weighted Items** | Items flagged `ageRestricted: true` or `soldByWeight: true` halt phone self-checkout completion until staff authorization QR is scanned. |
| **Audit Trail** | All voids, refunds, cart item deletions, and manual price overrides generate immutable audit records tied to cashier/staff IDs. |

---

## 6. Recommended Unified TRIXX Java Backend Architecture

To ensure consistency in pricing, inventory stock, and sales reporting across all channels, TRIXX utilizes a single shared Java backend service architecture.

```
+-------------------------------------------------------------------------+
|                              CLIENT LAYER                               |
|                                                                         |
|  +--------------------+   +-----------------------+   +--------------+  |
|  | Phone App / PWA    |   | SmartTrolley Controller|   | Cashier Till |  |
|  | (Camera Scanner)   |   | (Embedded Scanner)    |   | (POS System) |  |
|  +---------+----------+   +-----------+-----------+   +-------+------+  |
+------------|--------------------------|-------------------|-------------+
             |                          |                   |
             +------------------+-------+-------+-----------+
                                | REST / JSON   |
                                v               v
+-------------------------------------------------------------------------+
|                          TRIXX JAVA BACKEND                             |
|                                                                         |
|  +---------------------+  +--------------------+  +------------------+  |
|  |  Session Service    |  |  Catalog & Pricing |  | Cart Management  |  |
|  +---------------------+  +--------------------+  +------------------+  |
|  |  M-Pesa Payment Svc |  |  Stock Ledger Svc  |  | Receipt Service  |  |
|  +---------------------+  +--------------------+  +------------------+  |
|                                                                         |
|  +-------------------------------------------------------------------+  |
|  |                        SHARED DATA LAYER                          |  |
|  |  [Branch Catalog]  [Inventory Ledger]  [Order & Sales Database]  |  |
|  +-------------------------------------------------------------------+  |
+-------------------------------------------------------------------------+
```

### Shared Backend Core Services:
- **Branch Catalog & Pricing Service:** Single source of truth for barcode lookups, branch-specific pricing, and promotion rules.
- **Stock / Inventory Ledger:** Single ledger updating inventory stock count synchronously upon verified order payment regardless of purchase channel.
- **Cart & Order Processing:** Standardized cart calculation logic ensuring exact tax, discount, and total computations across Phone, SmartTrolley, and POS.
- **Payment Verification Service:** Unified M-Pesa API integration layer supporting STK push and C2B payment validation.
- **Receipt & Verification Service:** Centralized digital receipt issuance and exit pass cryptographic signing.
