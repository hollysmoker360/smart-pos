import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scanflow_pos/src/pos_api.dart';

void main() {
  test('quote sends the selected branch and cart to the server', () async {
    late http.Request captured;
    final api = HttpPosApi(
      baseUrl: 'http://localhost:8080/api/v1',
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'branchId': 'branch-1',
            'currency': 'KES',
            'items': [],
            'subtotalAmount': 100,
            'taxAmount': 16,
            'totalAmount': 116,
            'itemCount': 1,
          }),
          200,
        );
      }),
    );

    final quote = await api.quote('staff-token', 'branch-1', {'SKU-1': 1});

    expect(captured.url.path, '/api/v1/pos/quotes');
    expect(captured.headers['Authorization'], 'Bearer staff-token');
    expect(jsonDecode(captured.body), {
      'branchId': 'branch-1',
      'items': [
        {'productId': 'SKU-1', 'quantity': 1},
      ],
    });
    expect(quote.total, 116);
    api.close();
  });
}
