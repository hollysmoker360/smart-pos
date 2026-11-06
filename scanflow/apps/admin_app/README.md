# ScanFlow Admin

The ScanFlow platform administration interface is a Flutter web app. It
provides a platform-admin-only sign-in and creates business-owner invitations
through the authenticated backend API. The business and branch listing API is
not yet available, so the app does not display placeholder tenant metrics.

Run locally:

```sh
flutter pub get
flutter run -d web-server --web-port 5173 \
  --dart-define=SCANFLOW_API_BASE_URL=http://localhost:8080/api/v1
```

Deploy to static hosting:

```sh
flutter build web \
  --dart-define=SCANFLOW_API_BASE_URL=https://api.example.com/api/v1
```

The API must allow requests from the deployed admin origin. Platform
administrator accounts are provisioned by trusted operators; business owners
are onboarded using invitation links created in the app. Link delivery is not
automatic and must use an approved channel.

Sections without an implemented backend endpoint are explicitly marked
unavailable rather than populated with demo or fabricated business data.

Validate with `flutter analyze` and `flutter test`.
