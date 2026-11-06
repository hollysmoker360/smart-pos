import 'dart:math';

import 'package:flutter/foundation.dart';

import 'pos_api.dart';
import 'pos_models.dart';
import 'pos_session_store.dart';

enum PosAppStatus { initializing, signedOut, signedIn }

class PosCartLine {
  const PosCartLine({required this.product, required this.quantity});

  final PosProduct product;
  final int quantity;
}

class PosController extends ChangeNotifier {
  PosController({required PosApi api, required PosSessionStore sessionStore})
      : _api = api,
        _sessionStore = sessionStore;

  final PosApi _api;
  final PosSessionStore _sessionStore;
  PosAppStatus _status = PosAppStatus.initializing;
  PosAppStatus get status => _status;
  PosUser? _user;
  PosUser? get user => _user;
  List<PosBranch> _branches = const [];
  List<PosBranch> get branches => List.unmodifiable(_branches);
  List<PosProduct> _products = const [];
  List<PosProduct> get products => List.unmodifiable(_products);
  final Map<String, PosCartLine> _cart = {};
  List<PosCartLine> get cart => List.unmodifiable(_cart.values);
  Map<String, int> get cartIdentifiers => {
        for (final line in _cart.values) line.product.sku: line.quantity,
      };
  PosQuote? _quote;
  PosQuote? get quote => _quote;
  PosReceipt? _receipt;
  PosReceipt? get receipt => _receipt;
  String? _selectedBranchId;
  String? get selectedBranchId => _selectedBranchId;
  PosBranch? get selectedBranch {
    for (final branch in _branches) {
      if (branch.id == _selectedBranchId) return branch;
    }
    return null;
  }

  String? _token;
  bool _isBusy = false;
  bool get isBusy => _isBusy;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  String? _checkoutKey;

  Future<void> restoreSession() async {
    try {
      _token = await _sessionStore.readToken();
      if (_token == null || _token!.isEmpty) {
        _status = PosAppStatus.signedOut;
        return;
      }
      await _loadWorkspace();
      _status = PosAppStatus.signedIn;
    } on PosApiException catch (error) {
      _errorMessage = error.message;
      if (error.statusCode == 401) await _clearSession();
      _status = PosAppStatus.signedOut;
    } catch (error) {
      _errorMessage = _readableError(error);
      _status = PosAppStatus.signedOut;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      final session = await _api.login(email, password);
      if (!{'OWNER', 'BRANCH_MANAGER', 'CASHIER'}.contains(session.user.role)) {
        throw const PosApiException(
          403,
          'This app is for owners, branch managers, and cashiers.',
        );
      }
      _token = session.token;
      _user = session.user;
      await _sessionStore.writeToken(session.token);
      await _loadWorkspace();
      _status = PosAppStatus.signedIn;
      return true;
    } catch (error) {
      _errorMessage = _readableError(error);
      _status = PosAppStatus.signedOut;
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _loadWorkspace() async {
    final token = _requireToken();
    _branches = await _api.getBranches(token);
    if (_branches.isEmpty) {
      _selectedBranchId = null;
      _products = const [];
      return;
    }
    if (!_branches.any((branch) => branch.id == _selectedBranchId)) {
      _selectedBranchId = _branches.first.id;
    }
    _products = await _api.getProducts(token);
  }

  Future<void> selectBranch(String branchId) async {
    if (!_branches.any((branch) => branch.id == branchId)) {
      _errorMessage = 'Select a branch assigned to your account.';
      notifyListeners();
      return;
    }
    _selectedBranchId = branchId;
    _cart.clear();
    _quote = null;
    _checkoutKey = null;
    _errorMessage = null;
    await refreshProducts();
  }

  Future<void> refreshProducts() async {
    _setBusy(true);
    _errorMessage = null;
    try {
      _products = await _api.getProducts(_requireToken());
    } catch (error) {
      _errorMessage = _readableError(error);
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> addProduct(String identifier) async {
    if (_selectedBranchId == null) {
      _errorMessage = 'Choose an authorized branch first.';
      notifyListeners();
      return false;
    }
    _setBusy(true);
    _errorMessage = null;
    try {
      final product = await _api.lookupProduct(_requireToken(), identifier);
      final current = _cart[product.id]?.quantity ?? 0;
      if (current + 1 > product.stock) {
        throw const PosApiException(400, 'Requested quantity exceeds stock.');
      }
      _cart[product.id] = PosCartLine(product: product, quantity: current + 1);
      _quote = null;
      _checkoutKey = null;
      await _refreshQuote();
      return true;
    } catch (error) {
      _errorMessage = _readableError(error);
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final line = _cart[productId];
    if (line == null) return;
    if (quantity < 1) {
      _cart.remove(productId);
    } else if (quantity > line.product.stock) {
      _errorMessage = 'Requested quantity exceeds stock.';
      notifyListeners();
      return;
    } else {
      _cart[productId] = PosCartLine(product: line.product, quantity: quantity);
    }
    _quote = null;
    _checkoutKey = null;
    await refreshQuote();
  }

  Future<void> refreshQuote() async {
    if (_cart.isEmpty) {
      _quote = null;
      notifyListeners();
      return;
    }
    _setBusy(true);
    _errorMessage = null;
    try {
      await _refreshQuote();
    } catch (error) {
      _errorMessage = _readableError(error);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _refreshQuote() async {
    final branchId = _selectedBranchId;
    if (branchId == null) throw StateError('Choose a branch first.');
    _quote = await _api.quote(_requireToken(), branchId, cartIdentifiers);
    notifyListeners();
  }

  Future<bool> completeCashSale(String cashReceivedInput) async {
    final quote = _quote;
    final branchId = _selectedBranchId;
    if (quote == null || branchId == null || _cart.isEmpty) {
      _errorMessage = 'Refresh the server quote before checkout.';
      notifyListeners();
      return false;
    }
    final cashReceived = _moneyString(cashReceivedInput);
    if (cashReceived == null) {
      _errorMessage = 'Enter cash received to two decimal places.';
      notifyListeners();
      return false;
    }
    _setBusy(true);
    _errorMessage = null;
    _checkoutKey ??= _newIdempotencyKey();
    try {
      _receipt = await _api.checkout(
        token: _requireToken(),
        branchId: branchId,
        items: cartIdentifiers,
        idempotencyKey: _checkoutKey!,
        cashReceived: cashReceived,
      );
      _cart.clear();
      _quote = null;
      _checkoutKey = null;
      await refreshProducts();
      return true;
    } catch (error) {
      _errorMessage = _readableError(error);
      return false;
    } finally {
      _setBusy(false);
    }
  }

  void clearReceipt() {
    _receipt = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _clearSession();
    _branches = const [];
    _products = const [];
    _cart.clear();
    _quote = null;
    _receipt = null;
    _selectedBranchId = null;
    _errorMessage = null;
    _status = PosAppStatus.signedOut;
    notifyListeners();
  }

  Future<void> _clearSession() async {
    await _sessionStore.clear();
    _token = null;
    _user = null;
  }

  String _requireToken() {
    final token = _token;
    if (token == null || token.isEmpty) {
      throw const PosApiException(
        401,
        'Your session has ended. Sign in again.',
      );
    }
    return token;
  }

  String _readableError(Object error) {
    if (error is PosApiException) return error.message;
    if (error is FormatException) {
      return 'The server returned an invalid response.';
    }
    if (error is StateError) return error.message;
    return 'Could not reach ScanFlow. Check your connection and retry.';
  }

  String _newIdempotencyKey() {
    final random = Random.secure();
    final suffix = List.generate(
      4,
      (_) => random.nextInt(256),
    ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    return 'pos-${DateTime.now().microsecondsSinceEpoch}-$suffix';
  }

  String? _moneyString(String input) {
    final value = input.trim();
    final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(value);
    if (match == null) return null;
    final whole = BigInt.tryParse(match.group(1)!);
    if (whole == null) return null;
    final fraction = (match.group(2) ?? '').padRight(2, '0');
    return '$whole.$fraction';
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
