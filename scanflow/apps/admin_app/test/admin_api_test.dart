import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scanflow_admin/src/admin_api.dart';

void main() {
  test(
    'business invitations use the authenticated platform endpoint',
    () async {
      late http.Request capturedRequest;
      final api = HttpAdminApi(
        baseUrl: 'http://localhost:8080/api/v1',
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'invitationId': 'invitation-1',
              'businessName': 'Market One',
              'ownerEmail': 'owner@example.test',
              'invitationUrl':
                  'https://scanflow.example/accept-invitation?token=opaque',
              'expiresAt': '2026-11-13T10:00:00Z',
            }),
            201,
          );
        }),
      );

      final invitation = await api.inviteBusiness(
        token: 'platform-token',
        businessName: ' Market One ',
        ownerName: ' Owner One ',
        ownerEmail: ' owner@example.test ',
        ownerPhone: '+254712345678',
      );

      expect(capturedRequest.url.path, '/api/v1/platform/business-invitations');
      expect(capturedRequest.headers['Authorization'], 'Bearer platform-token');
      expect(jsonDecode(capturedRequest.body), {
        'businessName': 'Market One',
        'ownerName': 'Owner One',
        'ownerEmail': 'owner@example.test',
        'ownerPhone': '+254712345678',
      });
      expect(
        invitation.invitationUrl,
        'https://scanflow.example/accept-invitation?token=opaque',
      );
      api.close();
    },
  );

  test('login API errors are reported explicitly', () async {
    final api = HttpAdminApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'message': 'Invalid email or password'}),
          401,
        ),
      ),
    );

    await expectLater(
      api.login('admin@example.test', 'wrong'),
      throwsA(
        isA<AdminApiException>()
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
