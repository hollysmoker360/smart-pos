import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TrixxApiService {
  TrixxApiService({String? baseUrl, http.Client? client})
    : baseUrl = resolveBaseUrl(
        configuredBaseUrl: baseUrl ?? _configuredBaseUrl,
        isWeb: kIsWeb,
      ),
      client = client ?? http.Client();

  static const _configuredBaseUrl = String.fromEnvironment(
    'SCANFLOW_API_BASE_URL',
  );

  final String baseUrl;
  final http.Client client;

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
      headers['X-Shopping-Session-Token'] = token.trim();
    }
    return headers;
  }

  Future<Map<String, dynamic>> createShoppingSession({
    required String branchName,
    required String sessionType,
    required String token,
  }) async {
    return _request(
      client.post(
        Uri.parse('$baseUrl/shopping-sessions'),
        headers: getHeaders(token: token),
        body: jsonEncode({
          'branchName': branchName,
          'sessionType': sessionType,
        }),
      ),
    );
  }

  Future<Map<String, dynamic>> addBasketItem({
    required String sessionId,
    required String productIdentifier,
    required int quantity,
    required String token,
  }) async {
    return _request(
      client.post(
        Uri.parse('$baseUrl/shopping-sessions/$sessionId/items'),
        headers: getHeaders(token: token),
        body: jsonEncode({
          'productIdentifier': productIdentifier,
          'quantity': quantity,
        }),
      ),
    );
  }

  Future<Map<String, dynamic>> getBasket({
    required String sessionId,
    required String token,
  }) async {
    return _request(
      client.get(
        Uri.parse('$baseUrl/shopping-sessions/$sessionId/basket'),
        headers: getHeaders(token: token),
      ),
    );
  }

  Future<Map<String, dynamic>> checkout({
    required String branchId,
    required List<Map<String, dynamic>> items,
    required String token,
  }) async {
    return _request(
      client.post(
        Uri.parse('$baseUrl/pos/checkouts'),
        headers: getHeaders(token: token),
        body: jsonEncode({'branchId': branchId, 'items': items}),
      ),
    );
  }

  Future<Map<String, dynamic>> verifyExitToken(String tokenCode) async {
    return _request(
      client.post(
        Uri.parse('$baseUrl/public/exit-tokens/$tokenCode/verify'),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<Map<String, dynamic>> _request(Future<http.Response> pending) async {
    final response = await pending;
    final dynamic decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } on FormatException {
      throw TrixxApiException(response.statusCode, response.body);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw TrixxApiException(
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

class TrixxApiException implements Exception {
  const TrixxApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'API request failed ($statusCode): $message';
}
