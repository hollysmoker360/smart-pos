import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String baseUrl = kIsWeb ? 'http://localhost:8080/api/v1' : 'http://10.0.2.2:8080/api/v1';

  static Map<String, String> getHeaders({String? tenantId, String? branchId, String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (tenantId != null) headers['X-Tenant-ID'] = tenantId;
    if (branchId != null) headers['X-Branch-ID'] = branchId;
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  static Future<List<dynamic>> getBranches() async {
    final response = await http.get(Uri.parse('$baseUrl/stores'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load branches');
  }

  static Future<Map<String, dynamic>> createShoppingSession(String tenantId, String branchId, String? guestPhone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shopping-sessions'),
      headers: getHeaders(tenantId: tenantId, branchId: branchId),
      body: jsonEncode({'tenantId': tenantId, 'branchId': branchId, 'guestPhone': guestPhone}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to create shopping session');
  }

  static Future<Map<String, dynamic>> resolveBarcode(String branchId, String barcode) async {
    final response = await http.get(Uri.parse('$baseUrl/stores/$branchId/products/$barcode'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Barcode not found: $barcode');
  }

  static Future<Map<String, dynamic>> addItemToBasket(String sessionId, String barcode, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shopping-sessions/$sessionId/items'),
      headers: getHeaders(),
      body: jsonEncode({'barcode': barcode, 'quantity': quantity}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to add item to basket');
  }

  static Future<Map<String, dynamic>> updateItemQuantity(String sessionId, String itemId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/shopping-sessions/$sessionId/items/$itemId'),
      headers: getHeaders(),
      body: jsonEncode({'quantity': quantity}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to update quantity');
  }

  static Future<Map<String, dynamic>> checkout(String sessionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/checkout'),
      headers: getHeaders(),
      body: jsonEncode({'sessionId': sessionId}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Checkout failed');
  }

  static Future<Map<String, dynamic>> initiateMpesaPayment(String orderId, String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/payments/mpesa'),
      headers: getHeaders(),
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('M-Pesa payment initiation failed');
  }

  static Future<Map<String, dynamic>> getReceipt(String orderId) async {
    final response = await http.get(Uri.parse('$baseUrl/orders/$orderId/receipt'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch receipt');
  }

  static Future<Map<String, dynamic>> getExitToken(String orderId) async {
    final response = await http.get(Uri.parse('$baseUrl/orders/$orderId/exit-token'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch exit token');
  }

  static Future<Map<String, dynamic>> verifyExitToken(String tokenHash) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exit/verify'),
      headers: getHeaders(),
      body: jsonEncode({'tokenHash': tokenHash}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Invalid or unrecognized Exit Pass token');
  }

  static Future<Map<String, dynamic>> completeExit(String tokenHash, bool inspectionPerformed, String? notes) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exit/complete'),
      headers: getHeaders(),
      body: jsonEncode({
        'tokenHash': tokenHash,
        'inspectionPerformed': inspectionPerformed,
        'notes': notes,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to complete exit');
  }

  static Future<Map<String, dynamic>> getSalesReport() async {
    final response = await http.get(Uri.parse('$baseUrl/reports/sales'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch sales report');
  }

  static Future<Map<String, dynamic>> getAdminOverview() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/overview'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch admin overview');
  }
}
