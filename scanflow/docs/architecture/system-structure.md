# ScanFlow System Structure

ScanFlow is one retail platform with role-specific applications, a shared backend, and independently authenticated store devices. All applications use the same backend services; business, branch, role, and device permissions determine which data and operations are available.

## Target repository structure

```text
SCANFLOW/
├── frontend/
│   ├── customer_app/
│   ├── business_app/
│   ├── admin_app/
│   ├── pos_app/
│   ├── staff_app/
│   ├── smart_trolley_app/
│   └── shared/
│       ├── authentication/
│       ├── networking/
│       ├── design_system/
│       ├── models/
│       ├── permissions/
│       └── utilities/
├── backend/
│   └── scanflow_api/
│       ├── auth/
│       ├── users/
│       ├── roles/
│       ├── permissions/
│       ├── businesses/
│       ├── branches/
│       ├── products/
│       ├── inventory/
│       ├── qr/
│       ├── pos/
│       ├── shopping/
│       ├── orders/
│       ├── payments/
│       ├── devices/
│       ├── rfid/
│       ├── exit_verification/
│       ├── subscriptions/
│       ├── reporting/
│       ├── notifications/
│       └── audit/
├── device_services/
│   ├── rfid_gateway/
│   ├── exit_station/
│   └── hardware_integrations/
├── infrastructure/
│   ├── docker/
│   ├── nginx/
│   ├── monitoring/
│   ├── database/
│   └── deployment/
└── documentation/
    ├── architecture/
    ├── api/
    ├── security/
    └── user_manuals/
```

## Current implementation locations

The repository is being migrated toward the target layout incrementally. Existing application and backend paths remain in place until their code and build configuration can be moved together.

| Target area | Current location | Status |
| --- | --- | --- |
| Customer and shared customer experience | `apps/customer_app/` | Flutter application with shopping, scanning, basket, and checkout flows |
| SmartTrolley | `apps/smart_trolley/` | Flutter application with trolley, basket, checkout, and receipt flows |
| Admin web | `apps/admin_web/` | Existing web interface |
| POS application | `apps/pos_app/` | Reserved; implementation not yet present |
| Business and staff applications | Not yet present | Planned role-specific experiences |
| Shared Flutter packages | Not yet extracted | Avoid duplicating app code until package boundaries are established |
| Spring Boot API | `backend/` | Existing API, domain, security, service, repository, and database migration code |
| Device and hardware services | `hardware/` | Protocol and controller-firmware placeholders; device services not yet implemented |
| Infrastructure | `infra/` | Existing CI and Docker placeholders |
| API documentation | `docs/api/` | OpenAPI contract |

## Architecture boundaries

- The backend is authoritative for authorization, business and branch isolation, pricing, stock reservations, payments, and exit decisions.
- Humans use central accounts and scoped role assignments. Registered terminals, trolleys, readers, and exit stations use distinct device credentials.
- Checkout channels share order and payment services rather than implementing independent transaction rules in each app.
- Shared frontend packages should contain reusable capabilities such as authentication, networking, design, models, and permissions; role-specific navigation and workflows remain in their respective applications.
- Device integrations communicate through authenticated backend interfaces and cannot assert payment success or bypass server-side authorization.
- Database changes are versioned and applied through the backend migration system. API contract changes are documented in `docs/api/openapi.yaml`.

## Migration guidance

Move an existing application or service only when its source, tests, manifests, scripts, and documentation can be updated together. Keep the current build paths working during each migration; do not create a second implementation of an existing app or service in the target tree.
