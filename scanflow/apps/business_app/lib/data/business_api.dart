import 'dart:convert';

import 'package:http/http.dart' as http;

import 'business_models.dart';

abstract interface class BusinessApi {
  Future<AuthSession> login(String email, String password);
  Future<AuthSession> registerBusiness({
    required String businessName,
    required String ownerName,
    required String email,
    required String phone,
    required String password,
  });
  Future<AuthSession> acceptBusinessInvitation(
    String token,
    String password,
  );
  Future<CurrentUser> getCurrentUser(String token);
  Future<List<BranchSummary>> getBranches(String token);
  Future<BranchSummary> createBranch({
    required String token,
    required String name,
    required String currency,
    required String timezone,
  });
  Future<EmployeeInvitation> inviteEmployee({
    required String token,
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required List<String> branchIds,
  });
}

class BusinessApiException implements Exception {
  const BusinessApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class HttpBusinessApi implements BusinessApi {
  HttpBusinessApi({
    http.Client? client,
    String baseUrl = const String.fromEnvironment(
      'SCANFLOW_API_BASE_URL',
      defaultValue: 'http://localhost:8080/api/v1',
    ),
    this.timeout = const Duration(seconds: 15),
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;
  final Duration timeout;

  void close() => _client.close();

  @override
  Future<AuthSession> login(String email, String password) async {
    final response = await _send(
      'POST',
      '/auth/login',
      body: {'email': email.trim(), 'password': password},
    );
    return AuthSession.fromJson(response);
  }

  @override
  Future<AuthSession> registerBusiness({
    required String businessName,
    required String ownerName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _send(
      'POST',
      '/auth/register',
      body: {
        'businessName': businessName.trim(),
        'ownerName': ownerName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
      },
    );
    return AuthSession.fromJson(response);
  }

  @override
  Future<AuthSession> acceptBusinessInvitation(
    String token,
    String password,
  ) async {
    final response = await _send(
      'POST',
      '/auth/invitations/accept',
      body: {'token': token.trim(), 'password': password},
    );
    return AuthSession.fromJson(response);
  }

  @override
  Future<CurrentUser> getCurrentUser(String token) async {
    final response = await _send('GET', '/auth/me', token: token);
    return CurrentUser.fromJson(response);
  }

  @override
  Future<List<BranchSummary>> getBranches(String token) async {
    final response =
        await _send('GET', '/businesses/me/branches', token: token);
    final values = response['branches'] ?? response['data'] ?? response;
    if (values is! List<dynamic>) {
      throw const FormatException('Branch response must be a JSON array');
    }
    return values.map((branch) {
      if (branch is! Map<String, dynamic>) {
        throw const FormatException('Branch entry must be a JSON object');
      }
      return BranchSummary.fromJson(branch);
    }).toList(growable: false);
  }

  @override
  Future<BranchSummary> createBranch({
    required String token,
    required String name,
    required String currency,
    required String timezone,
  }) async {
    final response = await _send(
      'POST',
      '/businesses/me/branches',
      token: token,
      body: {
        'name': name.trim(),
        'currency': currency,
        'timezone': timezone,
      },
    );
    return BranchSummary.fromJson(response);
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
    final response = await _send(
      'POST',
      '/businesses/me/employee-invitations',
      token: token,
      body: {
        'fullName': fullName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role,
        'branchIds': branchIds,
      },
    );
    return EmployeeInvitation.fromJson(response);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    String? token,
    Map<String, Object?>? body,
  }) async {
    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers['Accept'] = 'application/json'
      ..headers['Content-Type'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) request.body = jsonEncode(body);

    final streamedResponse = await _client.send(request).timeout(timeout);
    final response =
        await http.Response.fromStream(streamedResponse).timeout(timeout);
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : _decodeObject(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded['message'];
      throw BusinessApiException(
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
