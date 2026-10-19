import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trixx_models.dart';

class TrixxApiService {
  final String baseUrl;

  TrixxApiService({this.baseUrl = 'http://localhost:8080'});

  Future<ShoppingSessionDto> claimTrolley({
    required String trolleyCode,
    required String customerId,
    required String branchId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/trolleys/claim'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'trolleyCode': trolleyCode,
        'customerId': customerId,
        'branchId': branchId,
      }),
    );

    if (response.statusCode == 200) {
      return ShoppingSessionDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to claim trolley: ${response.body}');
    }
  }

  Future<ShoppingBasketDto> sendScanEvent({
    required String deviceId,
    required String sessionId,
    required String barcode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/device-events/scans'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'eventId': 'evt_${DateTime.now().millisecondsSinceEpoch}',
        'deviceId': deviceId,
        'sessionId': sessionId,
        'barcode': barcode,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return ShoppingBasketDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to process scan: ${response.body}');
    }
  }

  Future<ShoppingBasketDto> getBasket(String sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/shopping-sessions/$sessionId/basket'),
    );

    if (response.statusCode == 200) {
      return ShoppingBasketDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to retrieve basket: ${response.body}');
    }
  }

  Future<ShoppingBasketDto> removeItem({
    required String sessionId,
    required String itemId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/shopping-sessions/$sessionId/items/$itemId'),
    );

    if (response.statusCode == 200) {
      return ShoppingBasketDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to remove item: ${response.body}');
    }
  }

  Future<CheckoutSnapshotDto> createCheckout(String sessionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/shopping-sessions/$sessionId/checkout'),
    );

    if (response.statusCode == 200) {
      return CheckoutSnapshotDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to freeze checkout: ${response.body}');
    }
  }

  Future<PaymentStatusDto> initiateMpesaPayment({
    required String orderId,
    required String phoneNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/orders/$orderId/payments/mpesa'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    if (response.statusCode == 200) {
      return PaymentStatusDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to initiate payment: ${response.body}');
    }
  }

  Future<PaymentStatusDto> getPaymentStatus(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/orders/$orderId/payment-status'),
    );

    if (response.statusCode == 200) {
      return PaymentStatusDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch payment status: ${response.body}');
    }
  }

  Future<ReceiptDto> getReceipt(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/orders/$orderId/receipt'),
    );

    if (response.statusCode == 200) {
      return ReceiptDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch receipt: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verifyExitToken(String tokenCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/exit/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'tokenCode': tokenCode}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify token: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> redeemExitToken({
    required String tokenCode,
    required String stationId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/exit/redeem'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tokenCode': tokenCode,
        'stationId': stationId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to redeem token: ${response.body}');
    }
  }

  Future<List<TrolleyDeviceDto>> getAdminTrolleys() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/admin/trolleys'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((d) => TrolleyDeviceDto.fromJson(d)).toList();
    } else {
      throw Exception('Failed to list trolleys: ${response.body}');
    }
  }

  Future<List<DiscrepancyDto>> getAdminDiscrepancies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/admin/discrepancies'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((d) => DiscrepancyDto.fromJson(d)).toList();
    } else {
      throw Exception('Failed to list discrepancies: ${response.body}');
    }
  }
}
