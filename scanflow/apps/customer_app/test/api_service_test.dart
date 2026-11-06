import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trixx_smartpos/services/api_service.dart';

void main() {
  test('API URL supports hosted HTTPS and local platform defaults', () {
    expect(
      ApiService.resolveBaseUrl(
        configuredBaseUrl: 'https://api.scanflow.example/api/v1/',
        isWeb: true,
      ),
      'https://api.scanflow.example/api/v1',
    );
    expect(
      ApiService.resolveBaseUrl(isWeb: true),
      'http://localhost:8080/api/v1',
    );
    expect(
      ApiService.resolveBaseUrl(isWeb: false),
      'http://10.0.2.2:8080/api/v1',
    );
  });

  test('guest session calls the public branch endpoint without fake identity',
      () async {
    final originalClient = ApiService.client;
    late http.Request capturedRequest;
    ApiService.client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'sessionId': 'session-1',
          'accessToken': 'opaque-capability',
          'branchId': 'branch-1',
          'branchName': 'Market One',
          'currency': 'KES',
          'guestCheckoutEnabled': true,
          'expiresAt': '2026-11-06T19:00:00Z',
        }),
        201,
      );
    });
    addTearDown(() => ApiService.client = originalClient);

    final session = await ApiService.createGuestSession('branch-1');

    expect(
      capturedRequest.url.path,
      '/api/v1/public/branches/branch-1/shopping-sessions',
    );
    expect(capturedRequest.headers.containsKey('Authorization'), isFalse);
    expect(session['accessToken'], 'opaque-capability');
  });

  test('basket stream parses server-sent snapshots with session capability',
      () async {
    final originalClient = ApiService.client;
    late http.Request capturedRequest;
    ApiService.client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        'event: basket.snapshot\n'
        'data: {"sessionId":"session-1","items":[],"totalAmount":0}\n\n',
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    });
    addTearDown(() => ApiService.client = originalClient);

    final snapshot = await ApiService.watchBasket(
      sessionId: 'session-1',
      sessionToken: 'opaque-capability',
    ).first;

    expect(capturedRequest.url.path,
        '/api/v1/public/shopping-sessions/session-1/events');
    expect(
      capturedRequest.headers['X-Shopping-Session-Token'],
      'opaque-capability',
    );
    expect(snapshot['totalAmount'], 0);
  });

  test('HTTP errors preserve API status and message', () async {
    final originalClient = ApiService.client;
    ApiService.client = MockClient(
      (_) async =>
          http.Response(jsonEncode({'message': 'Session expired'}), 403),
    );
    addTearDown(() => ApiService.client = originalClient);

    await expectLater(
      ApiService.getPublicBranch('branch-1'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 403)
            .having((error) => error.message, 'message', 'Session expired'),
      ),
    );
  });
}
