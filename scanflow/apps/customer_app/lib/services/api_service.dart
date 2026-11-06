import 'dart:async';
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
    final fallback =
        isWeb ? 'http://localhost:8080/api/v1' : 'http://10.0.2.2:8080/api/v1';
    final url = (configured.isEmpty ? fallback : configured).replaceFirst(
      RegExp(r'/+$'),
      '',
    );
    final parsed = Uri.tryParse(url);
    if (parsed == null ||
        !parsed.hasScheme ||
        !parsed.hasAuthority ||
        parsed.userInfo.isNotEmpty ||
        parsed.query.isNotEmpty ||
        parsed.fragment.isNotEmpty) {
      throw ArgumentError.value(configuredBaseUrl, 'configuredBaseUrl');
    }
    if (!kDebugMode && parsed.scheme != 'https') {
      throw ArgumentError.value(
        configuredBaseUrl,
        'configuredBaseUrl',
        'Production API URLs must use HTTPS',
      );
    }
    return url;
  }

  static Map<String, String> _headers({String? sessionToken}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (sessionToken != null && sessionToken.isNotEmpty) {
      headers['X-Shopping-Session-Token'] = sessionToken;
    }
    return headers;
  }

  static Future<Map<String, dynamic>> getPublicBranch(String branchId) async {
    final result = await _request('GET', '/public/branches/$branchId');
    if (result is Map<String, dynamic>) return result;
    throw const FormatException('Expected a branch object');
  }

  static Future<Map<String, dynamic>> createGuestSession(
    String branchId,
  ) async {
    final result = await _request(
      'POST',
      '/public/branches/$branchId/shopping-sessions',
    );
    if (result is Map<String, dynamic>) return result;
    throw const FormatException('Expected a shopping session object');
  }

  static Future<Map<String, dynamic>> addItemToBasket({
    required String sessionId,
    required String sessionToken,
    required String productIdentifier,
    required int quantity,
  }) async {
    final result = await _request(
      'POST',
      '/public/shopping-sessions/$sessionId/items',
      sessionToken: sessionToken,
      body: {'productIdentifier': productIdentifier, 'quantity': quantity},
    );
    if (result is Map<String, dynamic>) return result;
    throw const FormatException('Expected a basket object');
  }

  static Future<Map<String, dynamic>> updateBasketItem({
    required String sessionId,
    required String itemId,
    required String sessionToken,
    required int quantity,
  }) async {
    final result = await _request(
      'PATCH',
      '/public/shopping-sessions/$sessionId/items/$itemId',
      sessionToken: sessionToken,
      body: {'quantity': quantity},
    );
    if (result is Map<String, dynamic>) return result;
    throw const FormatException('Expected a basket object');
  }

  static Future<Map<String, dynamic>> removeBasketItem({
    required String sessionId,
    required String itemId,
    required String sessionToken,
  }) async {
    final result = await _request(
      'DELETE',
      '/public/shopping-sessions/$sessionId/items/$itemId',
      sessionToken: sessionToken,
    );
    if (result is Map<String, dynamic>) return result;
    throw const FormatException('Expected a basket object');
  }

  static Future<Map<String, dynamic>> getBasket({
    required String sessionId,
    required String sessionToken,
  }) async {
    final result = await _request(
      'GET',
      '/public/shopping-sessions/$sessionId/basket',
      sessionToken: sessionToken,
    );
    if (result is Map<String, dynamic>) return result;
    throw const FormatException('Expected a basket object');
  }

  static Stream<Map<String, dynamic>> watchBasket({
    required String sessionId,
    required String sessionToken,
  }) async* {
    final request = http.Request(
      'GET',
      Uri.parse('$baseUrl/public/shopping-sessions/$sessionId/events'),
    )
      ..headers.addAll(_headers(sessionToken: sessionToken))
      ..headers['Accept'] = 'text/event-stream';
    final response = await client.send(request).timeout(
          const Duration(seconds: 15),
        );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      throw ApiException(response.statusCode, _errorMessage(body));
    }

    final data = <String>[];
    await for (final line in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (line.isEmpty) {
        if (data.isNotEmpty) {
          final decoded = jsonDecode(data.join('\n'));
          if (decoded is! Map<String, dynamic>) {
            throw const FormatException('Expected a basket event object');
          }
          yield decoded;
          data.clear();
        }
      } else if (line.startsWith('data:')) {
        final value = line.substring(5);
        data.add(value.startsWith(' ') ? value.substring(1) : value);
      }
    }
  }

  static Future<dynamic> _request(
    String method,
    String path, {
    String? sessionToken,
    Map<String, Object?>? body,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers.addAll(_headers(sessionToken: sessionToken));
    if (body != null) request.body = jsonEncode(body);
    final stream = await client.send(request).timeout(
          const Duration(seconds: 15),
        );
    final response = await http.Response.fromStream(stream).timeout(
      const Duration(seconds: 15),
    );
    dynamic decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } on FormatException {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, _errorMessage(response.body));
    }
    return decoded;
  }

  static String _errorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> &&
          decoded['message'] is String &&
          (decoded['message'] as String).isNotEmpty) {
        return decoded['message'] as String;
      }
    } on FormatException {
      return body.isEmpty ? 'The API request failed.' : body;
    }
    return body.isEmpty ? 'The API request failed.' : body;
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'API request failed ($statusCode): $message';
}
