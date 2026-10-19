import 'package:flutter/material.dart';
import '../models/trixx_models.dart';
import '../services/trixx_api_service.dart';

class TrixxProvider with ChangeNotifier {
  final TrixxApiService apiService = TrixxApiService();

  ShoppingSessionDto? _currentSession;
  ShoppingBasketDto? _currentBasket;
  CheckoutSnapshotDto? _currentCheckout;
  PaymentStatusDto? _paymentStatus;
  ReceiptDto? _currentReceipt;
  List<TrolleyDeviceDto> _trolleys = [];
  List<DiscrepancyDto> _discrepancies = [];

  bool _isLoading = false;
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> claimTrolley({
    required String trolleyCode,
    required String customerId,
    required String branchId,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentSession = await apiService.claimTrolley(
        trolleyCode: trolleyCode,
        customerId: customerId,
        branchId: branchId,
      );
      await refreshBasket();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<void> refreshBasket() async {
    if (_currentSession == null) return;
    try {
      _currentBasket = await apiService.getBasket(_currentSession!.sessionId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> sendScanEvent(String barcode) async {
    if (_currentSession == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentBasket = await apiService.sendScanEvent(
        deviceId: _currentSession!.trolleyId,
        sessionId: _currentSession!.sessionId,
        barcode: barcode,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> removeItem(String itemId) async {
    if (_currentSession == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentBasket = await apiService.removeItem(
        sessionId: _currentSession!.sessionId,
        itemId: itemId,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createCheckout() async {
    if (_currentSession == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentCheckout = await apiService.createCheckout(_currentSession!.sessionId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> initiateMpesaPayment(String phoneNumber) async {
    if (_currentCheckout == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      _paymentStatus = await apiService.initiateMpesaPayment(
        orderId: _currentCheckout!.orderId,
        phoneNumber: phoneNumber,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<void> pollPaymentStatus() async {
    if (_currentCheckout == null) return;
    try {
      _paymentStatus = await apiService.getPaymentStatus(_currentCheckout!.orderId);
      if (_paymentStatus?.status == 'PAID') {
        _currentReceipt = await apiService.getReceipt(_currentCheckout!.orderId);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> redeemExitToken(String tokenCode) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await apiService.redeemExitToken(
        tokenCode: tokenCode,
        stationId: 'EXIT_STATION_01',
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadAdminData() async {
    _setLoading(true);
    try {
      _trolleys = await apiService.getAdminTrolleys();
      _discrepancies = await apiService.getAdminDiscrepancies();
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
    }
  }
}
