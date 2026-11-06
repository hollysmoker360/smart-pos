import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow_admin/src/admin_api.dart';
import 'package:scanflow_admin/src/admin_app.dart';
import 'package:scanflow_admin/src/admin_controller.dart';

void main() {
  testWidgets('platform admin creates and sees a business owner invitation', (
    tester,
  ) async {
    final api = _FakeAdminApi();
    final sessionStore = _MemorySessionStore();
    final controller = AdminController(api: api, sessionStore: sessionStore);
    await controller.restoreSession();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminControllerProvider.overrideWith((ref) => controller)],
        child: const AdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('adminEmail')),
      'admin@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('adminPassword')),
      'admin-password',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Platform overview'), findsOneWidget);

    await tester.tap(find.byKey(const Key('openBusinessInvitation')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('businessName')), 'Market One');
    await tester.enterText(find.byKey(const Key('ownerName')), 'Owner One');
    await tester.enterText(
      find.byKey(const Key('ownerEmail')),
      'owner@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('ownerPhone')),
      '+254712345678',
    );
    await tester.tap(find.byKey(const Key('createInvitation')));
    await tester.pumpAndSettle();

    expect(find.text('Market One · owner@example.test'), findsOneWidget);
    expect(
      find.text('https://scanflow.example/accept-invitation?token=opaque'),
      findsOneWidget,
    );
    expect(api.invitedOwnerEmail, 'owner@example.test');
    expect(sessionStore.token, 'platform-token');
  });

  testWidgets('non-platform users are denied admin workspace', (tester) async {
    final api = _FakeAdminApi(role: 'OWNER');
    final controller = AdminController(
      api: api,
      sessionStore: _MemorySessionStore(),
    );
    await controller.restoreSession();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminControllerProvider.overrideWith((ref) => controller)],
        child: const AdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('adminEmail')),
      'owner@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('adminPassword')),
      'owner-password',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('restricted to ScanFlow platform'),
      findsOneWidget,
    );
    expect(find.text('Platform overview'), findsNothing);
  });
}

class _MemorySessionStore implements AdminSessionStore {
  String? token;

  @override
  Future<void> clear() async => token = null;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String value) async => token = value;
}

class _FakeAdminApi implements AdminApi {
  _FakeAdminApi({this.role = 'PLATFORM_ADMIN'});

  final String role;
  String? invitedOwnerEmail;

  AdminUser get _user => AdminUser(
    id: 'admin-1',
    email: 'admin@example.test',
    fullName: 'Platform Admin',
    role: role,
  );

  @override
  Future<AdminSession> login(String email, String password) async =>
      AdminSession(token: 'platform-token', user: _user);

  @override
  Future<AdminUser> getCurrentUser(String token) async => _user;

  @override
  Future<BusinessInvitation> inviteBusiness({
    required String token,
    required String businessName,
    required String ownerName,
    required String ownerEmail,
    required String ownerPhone,
  }) async {
    invitedOwnerEmail = ownerEmail;
    return BusinessInvitation(
      businessName: businessName,
      ownerEmail: ownerEmail,
      invitationUrl: 'https://scanflow.example/accept-invitation?token=opaque',
      expiresAt: DateTime.utc(2026, 11, 13),
    );
  }

  @override
  void close() {}
}
