import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const _configuredBaseUrl = String.fromEnvironment(
    'SCANFLOW_API_BASE_URL',
  );
  static final String baseUrl = resolveBaseUrl(
    configuredBaseUrl: _configuredBaseUrl,
    isWeb: kIsWeb,
  );
  static http.Client client = http.Client();

  static String resolveBaseUrl({
    required bool isWeb,
    String? configuredBaseUrl,
  }) {
    final configured = configuredBaseUrl?.trim() ?? '';
    final fallback = isWeb
        ? 'http://localhost:8080/api/v1'
        : 'http://10.0.2.2:8080/api/v1';
    return (configured.isEmpty ? fallback : configured).replaceFirst(
      RegExp(r'/+$'),
      '',
    );
  }

  static Map<String, String> getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }
    return headers;
  }

  static Future<List<dynamic>> getBranches({String? token}) async {
    final data = await _get('/businesses/me/branches', token: token);
    if (data is! List) {
      throw const FormatException('Expected a list of branches');
    }
    return data;
  }

  static Future<Map<String, dynamic>> createShoppingSession({
    required String branchName,
    required String sessionType,
    required String token,
  }) async {
    return _mapResponse(await client.post(
      Uri.parse('$baseUrl/shopping-sessions'),
      headers: getHeaders(token: token),
      body: jsonEncode({
        'sessionType': sessionType,
        'branchName': branchName,
      }),
    ));
  }

  static Future<Map<String, dynamic>> addItemToBasket({
    required String sessionId,
    required String productIdentifier,
    required int quantity,
    required String token,
  }) async {
    return _mapResponse(await client.post(
      Uri.parse('$baseUrl/shopping-sessions/$sessionId/items'),
      headers: getHeaders(token: token),
      body: jsonEncode({
        'productIdentifier': productIdentifier,
        'quantity': quantity,
      }),
    ));
  }

  static Future<Map<String, dynamic>> getBasket({
    required String sessionId,
    required String token,
  }) async {
    return _mapResponse(await client.get(
      Uri.parse('$baseUrl/shopping-sessions/$sessionId/basket'),
      headers: getHeaders(token: token),
    ));
  }

  static Future<Map<String, dynamic>> _get(
    String path, {
    String? token,
  }) async {
    return _mapResponse(await client.get(
      Uri.parse('$baseUrl$path'),
      headers: getHeaders(token: token),
    ));
  }

  static Map<String, dynamic> _mapResponse(http.Response response) {
    final dynamic decoded;
    try {
      decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    } on FormatException {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw ApiException(
        response.statusCode,
        message?.isNotEmpty == true ? message! : response.body,
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected an object response');
    }
    return decoded;
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'API request failed ($statusCode): $message';
}
