import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow_pos/src/pos_api.dart';
import 'package:scanflow_pos/src/pos_app.dart';
import 'package:scanflow_pos/src/pos_controller.dart';
import 'package:scanflow_pos/src/pos_models.dart';
import 'package:scanflow_pos/src/pos_session_store.dart';

void main() {
  testWidgets('cashier signs in, scans an item, and completes a cash sale', (
    tester,
  ) async {
    final api = _FakePosApi();
    final controller = PosController(
      api: api,
      sessionStore: _MemoryPosSessionStore(),
    );
    await controller.restoreSession();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [posControllerProvider.overrideWith((ref) => controller)],
        child: const ScanFlowPosApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('posEmail')),
      'cashier@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('posPassword')),
      'cashier-password',
    );
    await tester.tap(find.byKey(const Key('posSignIn')));
    await tester.pumpAndSettle();

    expect(find.text('West Branch'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('posScanInput')), 'SKU-1');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('KES 116.00'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('cashReceived')), '200');
    final completeSale = find.byKey(const Key('completeCashSale'));
    await tester.ensureVisible(completeSale);
    await tester.pumpAndSettle();
    await tester.tap(completeSale);
    await tester.pumpAndSettle();

    expect(find.text('Sale complete'), findsOneWidget);
    expect(find.text('Receipt POS-TEST-1'), findsOneWidget);
    expect(api.checkoutCount, 1);
    expect(api.lastCheckoutCashReceived, '200.00');
  });
}

class _MemoryPosSessionStore implements PosSessionStore {
  String? token;

  @override
  Future<void> clear() async => token = null;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String value) async => token = value;
}

class _FakePosApi implements PosApi {
  int checkoutCount = 0;
  String? lastCheckoutCashReceived;

  static const _branch = PosBranch(
    id: 'branch-1',
    name: 'West Branch',
    currency: 'KES',
  );
  static const _product = PosProduct(
    id: 'product-1',
    sku: 'SKU-1',
    name: 'Maize Flour',
    barcode: '6401234500010',
    price: 100,
    stock: 5,
  );

  @override
  Future<PosAuthSession> login(String email, String password) async =>
      const PosAuthSession(
        token: 'access-token',
        user: PosUser(fullName: 'Cashier One', role: 'CASHIER'),
      );

  @override
  Future<List<PosBranch>> getBranches(String token) async => [_branch];

  @override
  Future<List<PosProduct>> getProducts(String token) async => [_product];

  @override
  Future<PosProduct> lookupProduct(String token, String identifier) async =>
      _product;

  @override
  Future<PosQuote> quote(
    String token,
    String branchId,
    Map<String, int> items,
  ) async =>
      const PosQuote(
        currency: 'KES',
        items: [
          PosQuoteItem(
            productId: 'product-1',
            sku: 'SKU-1',
            name: 'Maize Flour',
            quantity: 1,
            unitPrice: 100,
            taxAmount: 16,
            lineTotal: 116,
          ),
        ],
        subtotal: 100,
        tax: 16,
        total: 116,
      );

  @override
  Future<PosReceipt> checkout({
    required String token,
    required String branchId,
    required Map<String, int> items,
    required String idempotencyKey,
    required String cashReceived,
  }) async {
    checkoutCount++;
    lastCheckoutCashReceived = cashReceived;
    return const PosReceipt(
      orderNumber: 'POS-TEST-1',
      currency: 'KES',
      total: 116,
      cashReceived: 200,
      changeDue: 84,
    );
  }
}
