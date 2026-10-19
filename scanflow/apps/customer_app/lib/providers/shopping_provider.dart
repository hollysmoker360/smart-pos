import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ShoppingProvider extends ChangeNotifier {
  String? tenantId;
  String? branchId;
  String? branchName;
  String? sessionId;

  List<dynamic> basketItems = [];
  Map<String, dynamic>? currentOrder;
  Map<String, dynamic>? currentReceipt;
  Map<String, dynamic>? currentExitToken;

  double get basketTotal {
    double total = 0.0;
    for (var item in basketItems) {
      total += (item['totalPrice'] as num).toDouble();
    }
    return total;
  }

  int get basketItemCount {
    int count = 0;
    for (var item in basketItems) {
      count += (item['quantity'] as num).toInt();
    }
    return count;
  }

  void setBranch(String tenant, String branch, String name) {
    tenantId = tenant;
    branchId = branch;
    branchName = name;
    notifyListeners();
  }

  Future<void> initSession(String guestPhone) async {
    if (tenantId == null || branchId == null) return;
    final res = await ApiService.createShoppingSession(tenantId!, branchId!, guestPhone);
    sessionId = res['id'];
    basketItems = res['items'] ?? [];
    notifyListeners();
  }

  Future<void> scanAndAddItem(String barcode, {int quantity = 1}) async {
    if (sessionId == null) return;
    final res = await ApiService.addItemToBasket(sessionId!, barcode, quantity);
    basketItems = res['items'] ?? [];
    notifyListeners();
  }

  Future<void> updateItemQuantity(String itemId, int quantity) async {
    if (sessionId == null) return;
    final res = await ApiService.updateItemQuantity(sessionId!, itemId, quantity);
    basketItems = res['items'] ?? [];
    notifyListeners();
  }

  Future<void> performCheckout() async {
    if (sessionId == null) return;
    final res = await ApiService.checkout(sessionId!);
    currentOrder = res;
    notifyListeners();
  }

  Future<void> payWithMpesa(String phone) async {
    if (currentOrder == null) return;
    final res = await ApiService.initiateMpesaPayment(currentOrder!['id'], phone);
    // Fetch generated receipt and exit token after payment initiation/completion
    final receipt = await ApiService.getReceipt(currentOrder!['id']);
    final exitPass = await ApiService.getExitToken(currentOrder!['id']);
    currentReceipt = receipt;
    currentExitToken = exitPass;
    notifyListeners();
  }

  void clearSession() {
    sessionId = null;
    basketItems = [];
    currentOrder = null;
    currentReceipt = null;
    currentExitToken = null;
    notifyListeners();
  }
}
