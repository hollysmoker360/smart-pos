import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'pos_models.dart';

abstract interface class PosApi {
  Future<PosAuthSession> login(String email, String password);
  Future<List<PosBranch>> getBranches(String token);
  Future<List<PosProduct>> getProducts(String token);
  Future<PosProduct> lookupProduct(String token, String identifier);
  Future<PosQuote> quote(String token, String branchId, Map<String, int> items);
  Future<PosReceipt> checkout({
    required String token,
    required String branchId,
    required Map<String, int> items,
    required String idempotencyKey,
    required String cashReceived,
  });
}

class PosApiException implements Exception {
  const PosApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class HttpPosApi implements PosApi {
  HttpPosApi({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = resolveBaseUrl(baseUrl);

  final http.Client _client;
  final String _baseUrl;

  static String resolveBaseUrl(String? configured) {
    final value = (configured ??
            const String.fromEnvironment('SCANFLOW_API_BASE_URL'))
        .trim();
    final fallback = kIsWeb
        ? 'http://localhost:8080/api/v1'
        : 'http://10.0.2.2:8080/api/v1';
    final base = (value.isEmpty ? fallback : value).replaceFirst(
      RegExp(r'/+$'),
      '',
    );
    final uri = Uri.tryParse(base);
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        uri.userInfo.isNotEmpty ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty) {
      throw ArgumentError.value(configured, 'baseUrl');
    }
    if (!kDebugMode && uri.scheme != 'https') {
      throw ArgumentError.value(
        configured,
        'baseUrl',
        'Production API URLs must use HTTPS',
      );
    }
    return base;
  }

  void close() => _client.close();

  @override
  Future<PosAuthSession> login(String email, String password) async =>
      PosAuthSession.fromJson(_object(await _send(
        'POST',
        '/auth/login',
        body: {'email': email.trim(), 'password': password},
      )));

  @override
  Future<List<PosBranch>> getBranches(String token) async {
    final response = await _send('GET', '/pos/branches', token: token);
    if (response is! List) {
      throw const FormatException('Branch response must be an array.');
    }
    return response
        .cast<Map<String, dynamic>>()
        .map(PosBranch.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<PosProduct>> getProducts(String token) async {
    final response = _object(await _send(
      'GET',
      '/products?page=0&size=100',
      token: token,
    ));
    final content = response['content'];
    if (content is! List) {
      throw const FormatException('Product response must contain a page.');
    }
    return content
        .cast<Map<String, dynamic>>()
        .map(PosProduct.fromJson)
        .toList(growable: false);
  }

  @override
  Future<PosProduct> lookupProduct(String token, String identifier) async =>
      PosProduct.fromJson(_object(await _send(
        'GET',
        '/products/lookup?identifier=${Uri.encodeQueryComponent(identifier)}',
        token: token,
      )));

  @override
  Future<PosQuote> quote(
    String token,
    String branchId,
    Map<String, int> items,
  ) async =>
      PosQuote.fromJson(_object(await _send(
        'POST',
        '/pos/quotes',
        token: token,
        body: {
          'branchId': branchId,
          'items': items.entries
              .map((entry) => {'productId': entry.key, 'quantity': entry.value})
              .toList(growable: false),
        },
      )));

  @override
  Future<PosReceipt> checkout({
    required String token,
    required String branchId,
    required Map<String, int> items,
    required String idempotencyKey,
    required String cashReceived,
  }) async =>
      PosReceipt.fromJson(_object(await _send(
        'POST',
        '/pos/checkouts',
        token: token,
        body: {
          'branchId': branchId,
          'idempotencyKey': idempotencyKey,
          'paymentMethod': 'CASH',
          'cashReceived': cashReceived,
          'items': items.entries
              .map((entry) => {'productId': entry.key, 'quantity': entry.value})
              .toList(growable: false),
        },
      )));

  Future<dynamic> _send(
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

    final stream = await _client.send(request).timeout(
          const Duration(seconds: 15),
        );
    final response =
        await http.Response.fromStream(stream).timeout(const Duration(seconds: 15));
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic> ? decoded['message'] : null;
      throw PosApiException(
        response.statusCode,
        message is String && message.isNotEmpty
            ? message
            : 'Request failed with status ${response.statusCode}.',
      );
    }
    return decoded;
  }

  Map<String, dynamic> _object(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('API response must be an object.');
  }
}
