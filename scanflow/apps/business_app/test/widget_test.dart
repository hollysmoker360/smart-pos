import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow_business/data/business_api.dart';
import 'package:scanflow_business/data/business_models.dart';
import 'package:scanflow_business/data/session_store.dart';
import 'package:scanflow_business/state/business_app_controller.dart';
import 'package:scanflow_business/ui/business_app.dart';

void main() {
  testWidgets('owner signs in, creates a branch, and invites a cashier',
      (tester) async {
    final api = _FakeBusinessApi();
    final controller = BusinessAppController(
      api: api,
      sessionStore: _MemorySessionStore(),
    );
    await controller.restoreSession();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          businessAppControllerProvider.overrideWith((ref) => controller),
        ],
        child: const ScanFlowBusinessApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('email')),
      'owner@example.test',
    );
    await tester.enterText(find.byKey(const Key('password')), 'valid-password');
    await tester.tap(find.text('Sign in').first);
    await tester.pumpAndSettle();

    expect(find.text('Sample Grocer'), findsOneWidget);
    expect(find.text('Main Branch'), findsOneWidget);

    await tester.tap(find.text('Add branch'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('branchName')), 'West Branch');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('West Branch'), findsOneWidget);

    await tester.ensureVisible(find.text('Invite employee'));
    await tester.tap(find.text('Invite employee'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('employeeName')),
      'Cashier One',
    );
    await tester.enterText(
      find.byKey(const Key('employeeEmail')),
      'cashier@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('employeePhone')),
      '+254712345678',
    );
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.tap(find.text('Send invitation'));
    await tester.pumpAndSettle();

    expect(find.text('Invitation created for cashier@example.test'),
        findsOneWidget);
    expect(api.invitedBranchIds, isNotEmpty);
    expect(find.textContaining('https://scanflow.example/invite/'),
        findsOneWidget);
  });
}

class _MemorySessionStore implements SessionStore {
  String? token;

  @override
  Future<void> clear() async => token = null;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String value) async => token = value;
}

class _FakeBusinessApi implements BusinessApi {
  final business = const BusinessSummary(
    id: 'business-1',
    name: 'Sample Grocer',
    status: 'ACTIVE',
  );
  final user = const UserSummary(
    id: 'user-1',
    email: 'owner@example.test',
    fullName: 'Store Owner',
    role: 'OWNER',
  );
  final _branches = <BranchSummary>[
    const BranchSummary(
      id: 'branch-1',
      name: 'Main Branch',
      currency: 'KES',
      timezone: 'Africa/Nairobi',
      active: true,
    ),
  ];
  List<String> invitedBranchIds = const [];

  @override
  Future<AuthSession> login(String email, String password) async =>
      AuthSession(token: 'access-token', user: user, business: business);

  @override
  Future<AuthSession> registerBusiness({
    required String businessName,
    required String ownerName,
    required String email,
    required String phone,
    required String password,
  }) async =>
      AuthSession(token: 'access-token', user: user, business: business);

  @override
  Future<AuthSession> acceptBusinessInvitation(
    String token,
    String password,
  ) async =>
      AuthSession(token: 'access-token', user: user, business: business);

  @override
  Future<CurrentUser> getCurrentUser(String token) async =>
      CurrentUser(user: user, business: business);

  @override
  Future<List<BranchSummary>> getBranches(String token) async =>
      List.unmodifiable(_branches);

  @override
  Future<BranchSummary> createBranch({
    required String token,
    required String name,
    required String currency,
    required String timezone,
  }) async {
    final branch = BranchSummary(
      id: 'branch-${_branches.length + 1}',
      name: name,
      currency: currency,
      timezone: timezone,
      active: true,
    );
    _branches.add(branch);
    return branch;
  }

  @override
  Future<EmployeeInvitation> inviteEmployee({
    required String token,
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required List<String> branchIds,
  }) async {
    invitedBranchIds = branchIds;
    return EmployeeInvitation(
      invitationId: 'invitation-1',
      email: email,
      role: role,
      invitationUrl: 'https://scanflow.example/invite/opaque-token',
      expiresAt: DateTime.utc(2026, 11, 9),
      branchIds: branchIds,
    );
  }
}
