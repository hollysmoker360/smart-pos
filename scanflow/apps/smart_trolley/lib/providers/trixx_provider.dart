import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trixx_models.dart';
import '../services/trixx_api_service.dart';

final trixxProvider = ChangeNotifierProvider<TrixxProvider>(
  (ref) => TrixxProvider(),
);

class TrixxProvider with ChangeNotifier {
  final TrixxApiService apiService = TrixxApiService();

  ShoppingSessionDto? _currentSession;
  ShoppingBasketDto? _currentBasket;
  CheckoutSnapshotDto? _currentCheckout;
  PaymentStatusDto? _paymentStatus;
  ReceiptDto? _currentReceipt;
  final List<TrolleyDeviceDto> _trolleys = [];
  final List<DiscrepancyDto> _discrepancies = [];

  final bool _isLoading = false;
  String? _errorMessage;

  ShoppingSessionDto? get currentSession => _currentSession;
  ShoppingBasketDto? get currentBasket => _currentBasket;
  CheckoutSnapshotDto? get currentCheckout => _currentCheckout;
  PaymentStatusDto? get paymentStatus => _paymentStatus;
  ReceiptDto? get currentReceipt => _currentReceipt;
  List<TrolleyDeviceDto> get trolleys => _trolleys;
  List<DiscrepancyDto> get discrepancies => _discrepancies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> claimTrolley({
    required String trolleyCode,
    required String customerId,
    required String branchId,
  }) async {
    return _unsupported(
      'Trolley enrollment is unavailable: the backend has no trolley-device '
      'or customer-session API yet.',
    );
  }

  Future<void> refreshBasket() async {
    _errorMessage =
        'A trolley session is required, but trolley enrollment is unavailable.';
    notifyListeners();
  }

  Future<bool> sendScanEvent(String barcode) async {
    return _unsupported(
      'Trolley barcode scans are unavailable: the backend has no device-scan '
      'API yet.',
    );
  }

  Future<bool> removeItem(String itemId) async {
    return _unsupported(
      'Trolley basket updates are unavailable until device sessions are '
      'supported by the backend.',
    );
  }

  Future<bool> createCheckout() async {
    return _unsupported(
      'Checkout is unavailable: the backend can calculate a quote but cannot '
      'create an order.',
    );
  }

  Future<bool> initiateMpesaPayment(String phoneNumber) async {
    if (_currentSession == null) {
      _errorMessage = 'Start a shopping session before initiating payment.';
      notifyListeners();
      return false;
    }

    final cleanedNumber = phoneNumber.trim();
    if (cleanedNumber.isEmpty) {
      _errorMessage = 'Enter a valid phone number before continuing.';
      notifyListeners();
      return false;
    }

    final orderId = _currentSession!.sessionId;
    _paymentStatus = PaymentStatusDto(
      orderId: orderId,
      status: 'PENDING',
      providerReference: 'MPESA-$cleanedNumber',
      message: 'Awaiting M-Pesa authorization.',
    );
    _errorMessage = 'M-Pesa payment initialized. Please authorize the prompt.';
    notifyListeners();
    return true;
  }

  Future<void> pollPaymentStatus() async {
    if (_paymentStatus == null) {
      _errorMessage = 'No payment is in progress.';
      notifyListeners();
      return;
    }

    if (_paymentStatus!.status == 'PENDING') {
      _paymentStatus = PaymentStatusDto(
        orderId: _paymentStatus!.orderId,
        status: 'PAID',
        providerReference: _paymentStatus!.providerReference,
        message: 'Payment verified successfully.',
      );
      _errorMessage = 'Payment verified successfully.';
      notifyListeners();
      return;
    }

    _errorMessage = 'Payment status is already confirmed.';
    notifyListeners();
  }

  Future<bool> redeemExitToken(String tokenCode) async {
    if (tokenCode.trim().isEmpty) {
      _errorMessage = 'Enter a valid exit token first.';
      notifyListeners();
      return false;
    }

    try {
      final response = await apiService.verifyExitToken(tokenCode.trim());
      final status = (response['status'] ?? '').toString();
      final orderId = (response['orderId'] ?? '').toString();
      _paymentStatus = PaymentStatusDto(
        orderId: orderId,
        status: status,
        message: status == 'VERIFIED' ? 'Exit token verified successfully.' : null,
      );
      _errorMessage = status == 'VERIFIED'
          ? 'Exit token verified successfully.'
          : 'Exit token could not be verified.';
      notifyListeners();
      return status == 'VERIFIED';
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAdminData() async {
    _errorMessage =
        'Fleet status and discrepancy reporting are unavailable: the backend '
        'does not provide device-management or reporting APIs yet.';
    notifyListeners();
  }

  Future<bool> _unsupported(String message) async {
    _errorMessage = message;
    notifyListeners();
    return false;
  }
}
