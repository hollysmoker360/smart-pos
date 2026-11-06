import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scanflow_business/data/business_api.dart';

void main() {
  test('login sends credentials to the implemented auth endpoint', () async {
    late http.Request capturedRequest;
    final api = HttpBusinessApi(
      baseUrl: 'http://localhost:8080/api/v1',
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'token': 'access-token',
            'business': {
              'id': 'business-1',
              'name': 'Sample Grocer',
              'status': 'ACTIVE',
            },
            'user': {
              'id': 'user-1',
              'email': 'owner@example.test',
              'fullName': 'Store Owner',
              'role': 'OWNER',
            },
          }),
          200,
        );
      }),
    );

    final response = await api.login(' owner@example.test ', 'secret');

    expect(capturedRequest.url.path, '/api/v1/auth/login');
    expect(jsonDecode(capturedRequest.body), {
      'email': 'owner@example.test',
      'password': 'secret',
    });
    expect(response.token, 'access-token');
    expect(response.user.role, 'OWNER');
    api.close();
  });

  test('API errors are surfaced without treating them as successful data',
      () async {
    final api = HttpBusinessApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'message': 'Invalid email or password'}),
          401,
        ),
      ),
    );

    await expectLater(
      api.login('owner@example.test', 'wrong'),
      throwsA(
        isA<BusinessApiException>()
            .having((error) => error.statusCode, 'statusCode', 401)
            .having(
              (error) => error.message,
              'message',
              'Invalid email or password',
            ),
      ),
    );
    api.close();
  });
}
