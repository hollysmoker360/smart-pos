# Production deployment

ScanFlow uses a Spring Boot REST API with PostgreSQL as the system of record.
Flutter clients issue authenticated HTTPS requests; realtime event delivery is
documented alongside the API once enabled. Do not treat cached or locally
entered values as authoritative for price, inventory, payment, or access.

## Local development

For a local-only run, start the backend with its default in-memory H2 database:

```sh
cd scanflow/backend
CORS_ALLOWED_ORIGINS=http://localhost:3000 APP_PUBLIC_URL=http://localhost:3000 ./gradlew bootRun
```

In another terminal, run the Business app as a Flutter web server:

```sh
cd scanflow/apps/business_app
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000 \
  --dart-define=SCANFLOW_API_BASE_URL=http://localhost:8080/api/v1
```

The H2 database is disposable and is not suitable for production data. For
PostgreSQL-backed schema verification, run
`cd scanflow/backend && ./gradlew test --tests '*PostgreSqlMigrationTests'`
with Docker available.

## Backend and database

The repository includes a production-profile API image and a PostgreSQL Compose
deployment:

1. Copy `.env.production.example` to `.env` on the deployment host.
2. Replace every example credential, use a unique JWT key with at least 32
   cryptographically random bytes, and set real HTTPS hostnames.
3. Configure `CORS_ALLOWED_ORIGINS` with the exact deployed Flutter origins.
4. Build and start with `docker compose --env-file .env -f
   compose.production.yaml up --build -d`.
5. Confirm the API readiness probe at `/actuator/health/readiness`, inspect
   Flyway startup logs, and verify PostgreSQL backups and restore procedures.

The API is configured to run with the `prod` Spring profile, schema validation,
Flyway migrations, graceful shutdown, and non-root container user. Keep
PostgreSQL private to the Compose network. Terminate TLS at a managed load
balancer or reverse proxy and expose only HTTPS to clients. Use a managed
PostgreSQL service with automated encrypted backups for production rather than
the single-host Compose database.

Never use the local H2 profile, development JWT fallback, open registration,
default passwords, or demo data in production. Provision the initial platform
administrator through deployment secrets and rotate/retire bootstrap
credentials after first use.

## Flutter web clients

Build `admin_app` and `business_app` with the API's public HTTPS URL:

```sh
cd apps/admin_app
flutter pub get
flutter build web \
  --dart-define=SCANFLOW_API_BASE_URL=https://api.example.com/api/v1
```

Publish `build/web` to a static host with HTTPS and a restrictive Content
Security Policy. Configure the API CORS allowlist for each exact app origin.
Build again for each environment; the API URL is compiled into the Flutter web
bundle and is not a secret. Do not publish a bundle built with localhost or an
example domain.

## CI

`.github/workflows/ci.yml` runs backend tests and Flutter analysis/tests for
the application packages, and builds the backend and web bundles. Deployment is
intentionally not automatic: configure a protected environment, host-specific
credentials, migrations/backup policy, and approval gates before enabling
release jobs.

## Operational readiness

Before onboarding real stores, also configure TLS, domain/DNS, alerting, log
retention, backup restore drills, rate limits, credential rotation, privacy
notices, and incident response. Review every product workflow against its
implemented API; a visible section is not production-ready until its operation
is backed by an authorized server endpoint and integration-tested.
