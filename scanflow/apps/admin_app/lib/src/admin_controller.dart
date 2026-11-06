import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'admin_api.dart';

final adminApiProvider = Provider<AdminApi>((ref) {
  final api = HttpAdminApi();
  ref.onDispose(api.close);
  return api;
});

final adminSessionStoreProvider = Provider<AdminSessionStore>(
  (ref) => SecureAdminSessionStore(),
);

final adminControllerProvider = ChangeNotifierProvider<AdminController>((ref) {
  final controller = AdminController(
    api: ref.watch(adminApiProvider),
    sessionStore: ref.watch(adminSessionStoreProvider),
  );
  unawaited(controller.restoreSession());
  return controller;
});

abstract interface class AdminSessionStore {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clear();
}

class SecureAdminSessionStore implements AdminSessionStore {
  SecureAdminSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'scanflow.platform_admin.access_token';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _tokenKey);
}

enum AdminStatus { initializing, signedOut, signedIn }

class AdminController extends ChangeNotifier {
  AdminController({required this._api, required this._sessionStore});

  final AdminApi _api;
  final AdminSessionStore _sessionStore;
  AdminStatus status = AdminStatus.initializing;
  AdminUser? user;
  bool isBusy = false;
  String? errorMessage;
  BusinessInvitation? lastInvitation;

  Future<void> restoreSession() async {
    if (status != AdminStatus.initializing) return;
    isBusy = true;
    notifyListeners();
    try {
      final token = await _sessionStore.readToken();
      if (token == null || token.isEmpty) {
        status = AdminStatus.signedOut;
        return;
      }
      final currentUser = await _api.getCurrentUser(token);
      _requirePlatformAdmin(currentUser);
      user = currentUser;
      status = AdminStatus.signedIn;
    } on AdminApiException catch (error) {
      errorMessage = error.message;
      status = AdminStatus.signedOut;
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _sessionStore.clear();
      }
    } catch (error) {
      errorMessage = _errorText(error);
      status = AdminStatus.signedOut;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      final session = await _api.login(email, password);
      _requirePlatformAdmin(session.user);
      await _sessionStore.writeToken(session.token);
      final currentUser = await _api.getCurrentUser(session.token);
      _requirePlatformAdmin(currentUser);
      user = currentUser;
      status = AdminStatus.signedIn;
      return true;
    } catch (error) {
      await _sessionStore.clear();
      errorMessage = _errorText(error);
      status = AdminStatus.signedOut;
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<BusinessInvitation?> inviteBusiness({
    required String businessName,
    required String ownerName,
    required String ownerEmail,
    required String ownerPhone,
  }) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      final token = await _sessionStore.readToken();
      if (token == null || token.isEmpty) {
        await signOut();
        errorMessage = 'Your session has ended. Please sign in again.';
        return null;
      }
      final invitation = await _api.inviteBusiness(
        token: token,
        businessName: businessName,
        ownerName: ownerName,
        ownerEmail: ownerEmail,
        ownerPhone: ownerPhone,
      );
      lastInvitation = invitation;
      return invitation;
    } catch (error) {
      errorMessage = _errorText(error);
      if (error is AdminApiException && error.statusCode == 401) {
        await signOut();
      }
      return null;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _sessionStore.clear();
    user = null;
    lastInvitation = null;
    status = AdminStatus.signedOut;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void _requirePlatformAdmin(AdminUser candidate) {
    if (candidate.role != 'PLATFORM_ADMIN') {
      throw const AdminApiException(
        403,
        'This app is restricted to ScanFlow platform administrators.',
      );
    }
  }

  String _errorText(Object error) {
    if (error is AdminApiException) return error.message;
    if (error is FormatException) {
      return 'The server returned an invalid response.';
    }
    return 'Could not reach ScanFlow. Check your connection and try again.';
  }
}
