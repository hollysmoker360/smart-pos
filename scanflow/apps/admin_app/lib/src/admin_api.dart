import 'dart:convert';

import 'package:http/http.dart' as http;

class AdminApiException implements Exception {
  const AdminApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: _string(json, 'id'),
    email: _string(json, 'email'),
    fullName: _string(json, 'fullName'),
    role: _string(json, 'role'),
  );
}

class BusinessInvitation {
  const BusinessInvitation({
    required this.businessName,
    required this.ownerEmail,
    required this.invitationUrl,
    required this.expiresAt,
  });

  final String businessName;
  final String ownerEmail;
  final String invitationUrl;
  final DateTime expiresAt;

  factory BusinessInvitation.fromJson(Map<String, dynamic> json) =>
      BusinessInvitation(
        businessName: _string(json, 'businessName'),
        ownerEmail: _string(json, 'ownerEmail'),
        invitationUrl: _string(json, 'invitationUrl'),
        expiresAt: DateTime.parse(_string(json, 'expiresAt')),
      );
}

abstract interface class AdminApi {
  Future<AdminSession> login(String email, String password);
  Future<AdminUser> getCurrentUser(String token);
  Future<BusinessInvitation> inviteBusiness({
    required String token,
    required String businessName,
    required String ownerName,
    required String ownerEmail,
    required String ownerPhone,
  });
  void close();
}

class AdminSession {
  const AdminSession({required this.token, required this.user});

  final String token;
  final AdminUser user;

  factory AdminSession.fromJson(Map<String, dynamic> json) => AdminSession(
    token: _string(json, 'token'),
    user: AdminUser.fromJson(_object(json, 'user')),
  );
}

class HttpAdminApi implements AdminApi {
  HttpAdminApi({
    http.Client? client,
    String baseUrl = const String.fromEnvironment(
      'SCANFLOW_API_BASE_URL',
      defaultValue: 'http://localhost:8080/api/v1',
    ),
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;

  @override
  void close() => _client.close();

  @override
  Future<AdminSession> login(String email, String password) async {
    final response = await _send(
      'POST',
      '/auth/login',
      body: {'email': email.trim(), 'password': password},
    );
    return AdminSession.fromJson(response);
  }

  @override
  Future<AdminUser> getCurrentUser(String token) async {
    final response = await _send('GET', '/auth/me', token: token);
    return AdminUser.fromJson(_object(response, 'user'));
  }

  @override
  Future<BusinessInvitation> inviteBusiness({
    required String token,
    required String businessName,
    required String ownerName,
    required String ownerEmail,
    required String ownerPhone,
  }) async {
    final response = await _send(
      'POST',
      '/platform/business-invitations',
      token: token,
      body: {
        'businessName': businessName.trim(),
        'ownerName': ownerName.trim(),
        'ownerEmail': ownerEmail.trim(),
        'ownerPhone': ownerPhone.trim(),
      },
    );
    return BusinessInvitation.fromJson(response);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    String? token,
    Map<String, String>? body,
  }) async {
    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers['Accept'] = 'application/json';
    if (body != null) {
      request
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);
    }
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 15));
    final response = await http.Response.fromStream(streamed)
        .timeout(const Duration(seconds: 15));
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : _decodeObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded['message'];
      throw AdminApiException(
        response.statusCode,
        message is String && message.isNotEmpty
            ? message
            : 'Request failed with status ${response.statusCode}',
      );
    }
    return decoded;
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('API response must be a JSON object');
  }
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Response is missing a valid "$key" value');
}

Map<String, dynamic> _object(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Response is missing a valid "$key" object');
}
