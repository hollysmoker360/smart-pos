# ScanFlow Business

The business app provides authenticated owner/business-administrator access to
the ScanFlow backend. It supports login, owner invitation acceptance,
development-only direct registration, branch listing and creation, and
branch-scoped employee invitations.

The dashboard uses live API responses; it does not display sample sales or
device metrics. Backend authorization remains authoritative. Access tokens are
stored through `flutter_secure_storage`; signing out clears the local token.
Server-side session revocation is not implemented yet, so a previously issued
JWT remains valid until its configured expiry.

## Run

From `scanflow/apps/business_app`:

```sh
flutter pub get
flutter run --dart-define=SCANFLOW_API_BASE_URL=http://localhost:8080/api/v1
```

Set `SCANFLOW_API_BASE_URL` to the reachable API URL for the target device.
Android emulators commonly reach a host API at `http://10.0.2.2:8080/api/v1`;
physical devices need the host's network address and a trusted HTTPS endpoint.

Direct business registration is disabled in production. In production, the
platform administrator creates an owner invitation, which can be accepted in
the app. Employee invitations are created by the backend and must be delivered
to employees through an approved channel; the app does not claim to send SMS
or email.

## Validate

```sh
flutter test
flutter analyze
flutter build web
```
