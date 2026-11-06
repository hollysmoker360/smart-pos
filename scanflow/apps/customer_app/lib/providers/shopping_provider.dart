import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_service.dart';

final shoppingProvider = ChangeNotifierProvider<ShoppingProvider>((ref) {
  final provider = ShoppingProvider(
    sessionStore: SecureShoppingSessionStore(),
  );
  unawaited(provider.restoreSession());
  ref.onDispose(provider.dispose);
  return provider;
});

abstract interface class ShoppingSessionStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> clear();
}

class SecureShoppingSessionStore implements ShoppingSessionStore {
  SecureShoppingSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _keys = [
    'scanflow.guest.session_id',
    'scanflow.guest.session_token',
    'scanflow.guest.branch_id',
    'scanflow.guest.branch_name',
    'scanflow.guest.currency',
  ];

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> clear() async {
    for (final key in _keys) {
      await _storage.delete(key: key);
    }
  }
}

class ShoppingProvider extends ChangeNotifier {
  ShoppingProvider({required ShoppingSessionStore sessionStore})
      : _sessionStore = sessionStore;

  static const _sessionIdKey = 'scanflow.guest.session_id';
  static const _sessionTokenKey = 'scanflow.guest.session_token';
  static const _branchIdKey = 'scanflow.guest.branch_id';
  static const _branchNameKey = 'scanflow.guest.branch_name';
  static const _currencyKey = 'scanflow.guest.currency';

  final ShoppingSessionStore _sessionStore;
  StreamSubscription<Map<String, dynamic>>? _basketSubscription;
  String? _branchId;
  String? _branchName;
  String? _currency;
  String? _sessionId;
  String? _sessionToken;
  List<Map<String, dynamic>> _basketItems = const [];
  double _basketTotal = 0;
  bool _isLoading = false;
  String? _errorMessage;

  String? get branchId => _branchId;
  String? get branchName => _branchName;
  String get currency => _currency ?? 'KES';
  String? get sessionId => _sessionId;
  List<Map<String, dynamic>> get basketItems => List.unmodifiable(_basketItems);
  double get basketTotal => _basketTotal;
  int get basketItemCount => _basketItems.fold<int>(
        0,
        (total, item) => total + (item['quantity'] as int),
      );
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    _setLoading(true);
    try {
      _sessionId = await _sessionStore.read(_sessionIdKey);
      _sessionToken = await _sessionStore.read(_sessionTokenKey);
      _branchId = await _sessionStore.read(_branchIdKey);
      _branchName = await _sessionStore.read(_branchNameKey);
      _currency = await _sessionStore.read(_currencyKey);
      if (_sessionId == null || _sessionToken == null || _branchId == null) {
        return;
      }
      await refreshBasket();
      _subscribeToBasket();
    } catch (error) {
      _errorMessage = _readableError(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> joinStore(String branchId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final branch = await ApiService.getPublicBranch(branchId.trim());
      if (branch['phoneScanningEnabled'] != true) {
        throw const ApiException(
            403, 'Phone scanning is not enabled at this store.');
      }
      final session = await ApiService.createGuestSession(branchId.trim());
      final sessionId = _stringValue(session, 'sessionId');
      final accessToken = _stringValue(session, 'accessToken');
      final name = _stringValue(branch, 'name');
      final currency = _stringValue(branch, 'currency');

      await _basketSubscription?.cancel();
      _branchId = branchId.trim();
      _branchName = name;
      _currency = currency;
      _sessionId = sessionId;
      _sessionToken = accessToken;
      await _sessionStore.write(_sessionIdKey, sessionId);
      await _sessionStore.write(_sessionTokenKey, accessToken);
      await _sessionStore.write(_branchIdKey, _branchId!);
      await _sessionStore.write(_branchNameKey, name);
      await _sessionStore.write(_currencyKey, currency);
      _applyBasket(const {'items': [], 'totalAmount': 0});
      _subscribeToBasket();
      return true;
    } catch (error) {
      _errorMessage = _readableError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> scanAndAddItem(String productIdentifier) async {
    final sessionId = _requireSessionId();
    final token = _requireSessionToken();
    _setLoading(true);
    _errorMessage = null;
    try {
      final basket = await ApiService.addItemToBasket(
        sessionId: sessionId,
        sessionToken: token,
        productIdentifier: productIdentifier,
        quantity: 1,
      );
      _applyBasket(basket);
    } catch (error) {
      _errorMessage = _readableError(error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateItemQuantity(String itemId, int quantity) async {
    final sessionId = _requireSessionId();
    final token = _requireSessionToken();
    _setLoading(true);
    _errorMessage = null;
    try {
      _applyBasket(await ApiService.updateBasketItem(
        sessionId: sessionId,
        itemId: itemId,
        sessionToken: token,
        quantity: quantity,
      ));
    } catch (error) {
      _errorMessage = _readableError(error);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeItem(String itemId) async {
    final sessionId = _requireSessionId();
    final token = _requireSessionToken();
    _setLoading(true);
    _errorMessage = null;
    try {
      _applyBasket(await ApiService.removeBasketItem(
        sessionId: sessionId,
        itemId: itemId,
        sessionToken: token,
      ));
    } catch (error) {
      _errorMessage = _readableError(error);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshBasket() async {
    final sessionId = _sessionId;
    final token = _sessionToken;
    if (sessionId == null || token == null) return;
    try {
      _applyBasket(await ApiService.getBasket(
        sessionId: sessionId,
        sessionToken: token,
      ));
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _readableError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearSession() async {
    await _basketSubscription?.cancel();
    _basketSubscription = null;
    await _sessionStore.clear();
    _branchId = null;
    _branchName = null;
    _currency = null;
    _sessionId = null;
    _sessionToken = null;
    _basketItems = const [];
    _basketTotal = 0;
    _errorMessage = null;
    notifyListeners();
  }

  void _subscribeToBasket() {
    final sessionId = _sessionId;
    final token = _sessionToken;
    if (sessionId == null || token == null) return;
    unawaited(_basketSubscription?.cancel());
    _basketSubscription = ApiService.watchBasket(
      sessionId: sessionId,
      sessionToken: token,
    ).listen(
      _applyBasket,
      onError: (Object error) {
        _errorMessage = _readableError(error);
        notifyListeners();
      },
    );
  }

  void _applyBasket(Map<String, dynamic> response) {
    final items = response['items'];
    if (items is! List) {
      throw const FormatException('The server returned an invalid basket.');
    }
    _basketItems = items.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
            'The server returned an invalid basket item.');
      }
      return <String, dynamic>{
        'id': _stringValue(item, 'id'),
        'productId': _stringValue(item, 'productId'),
        'productName': _stringValue(item, 'productName'),
        'productSku': _stringValue(item, 'productSku'),
        'quantity': _intValue(item, 'quantity'),
        'unitPrice': _doubleValue(item, 'unitPrice'),
        'lineTotal': _doubleValue(item, 'lineTotal'),
      };
    }).toList(growable: false);
    _basketTotal = _doubleValue(response, 'totalAmount');
    notifyListeners();
  }

  String _requireSessionId() =>
      _sessionId ?? (throw StateError('Join a store before shopping.'));

  String _requireSessionToken() =>
      _sessionToken ?? (throw StateError('Join a store before shopping.'));

  String _readableError(Object error) {
    if (error is ApiException) return error.message;
    if (error is FormatException) return error.message;
    if (error is StateError) return error.message;
    return 'Could not reach ScanFlow. Check your connection and try again.';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_basketSubscription?.cancel());
    super.dispose();
  }
}

String _stringValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('The server response is missing "$key".');
}

int _intValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toInt();
  throw FormatException('The server response is missing "$key".');
}

double _doubleValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toDouble();
  throw FormatException('The server response is missing "$key".');
}
