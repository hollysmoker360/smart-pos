import 'package:flutter_test/flutter_test.dart';
import 'package:trixx_app/models/trixx_models.dart';

void main() {
  group('Trixx Models Tests', () {
    test('ShoppingSessionDto parses JSON correctly', () {
      final json = {
        'sessionId': 'SESS-001',
        'customerId': 'CUST-1001',
        'trolleyId': 'TRL-001',
        'branchId': 'BRANCH-001',
        'status': 'ACTIVE',
        'createdAt': '2026-10-19T00:00:00Z',
      };

      final session = ShoppingSessionDto.fromJson(json);

      expect(session.sessionId, equals('SESS-001'));
      expect(session.customerId, equals('CUST-1001'));
      expect(session.trolleyId, equals('TRL-001'));
      expect(session.status, equals('ACTIVE'));
    });

    test('ShoppingBasketDto parses subtotal and items correctly', () {
      final json = {
        'basketId': 'BASKET-001',
        'sessionId': 'SESS-001',
        'version': 2,
        'subtotal': 250.0,
        'taxes': 40.0,
        'totalDiscounts': 0.0,
        'estimatedTotal': 290.0,
        'items': [
          {
            'itemId': 'ITEM-001',
            'productId': 'PROD-001',
            'productName': 'Fresh Milk 1L',
            'barcode': '6001234567890',
            'quantity': 2,
            'unitPrice': 125.0,
            'discount': 0.0,
            'lineTotal': 250.0,
          }
        ]
      };

      final basket = ShoppingBasketDto.fromJson(json);

      expect(basket.basketId, equals('BASKET-001'));
      expect(basket.version, equals(2));
      expect(basket.items.length, equals(1));
      expect(basket.items.first.productName, equals('Fresh Milk 1L'));
      expect(basket.estimatedTotal, equals(290.0));
    });
  });
}
