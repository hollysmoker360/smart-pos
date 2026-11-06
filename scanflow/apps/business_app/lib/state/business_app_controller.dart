import 'package:flutter/foundation.dart';

import '../data/business_api.dart';
import '../data/business_models.dart';
import '../data/session_store.dart';

enum BusinessAppStatus { initializing, signedOut, signedIn }

class BusinessAppController extends ChangeNotifier {
  BusinessAppController({
    required BusinessApi api,
    required SessionStore sessionStore,
  })  : _api = api,
        _sessionStore = sessionStore;

  final BusinessApi _api;
  final SessionStore _sessionStore;

  BusinessAppStatus _status = BusinessAppStatus.initializing;
  BusinessAppStatus get status => _status;

  CurrentUser? _currentUser;
  CurrentUser? get currentUser => _currentUser;

  List<BranchSummary> _branches = const [];
  List<BranchSummary> get branches => List.unmodifiable(_branches);

  EmployeeInvitation? _lastInvitation;
  EmployeeInvitation? get lastInvitation => _lastInvitation;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get canManageBusiness =>
      _currentUser?.user.role == 'OWNER' ||
      _currentUser?.user.role == 'BUSINESS_ADMIN';

  bool get canCreateBranches => _currentUser?.user.role == 'OWNER';

  Future<void> restoreSession() async {
    if (_status != BusinessAppStatus.initializing) return;
    _setBusy(true);
    try {
      final token = await _sessionStore.readToken();
      if (token == null || token.isEmpty) {
        _status = BusinessAppStatus.signedOut;
        return;
      }
      await _loadBusiness(token);
      _status = BusinessAppStatus.signedIn;
    } on BusinessApiException catch (error) {
      _errorMessage = error.message;
      _status = BusinessAppStatus.signedOut;
      if (error.statusCode == 401) await _sessionStore.clear();
    } catch (error) {
      _errorMessage = _readableError(error);
      _status = BusinessAppStatus.signedOut;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> signIn(String email, String password) =>
      _authenticate(() => _api.login(email, password));

  Future<bool> registerBusiness({
    required String businessName,
    required String ownerName,
    required String email,
    required String phone,
    required String password,
  }) =>
      _authenticate(
        () => _api.registerBusiness(
          businessName: businessName,
          ownerName: ownerName,
          email: email,
          phone: phone,
          password: password,
        ),
      );

  Future<bool> acceptBusinessInvitation(String token, String password) =>
      _authenticate(() => _api.acceptBusinessInvitation(token, password));

  Future<bool> _authenticate(
      Future<AuthSession> Function() authenticate) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      final authSession = await authenticate();
      _requireBusinessRole(authSession.user.role);
      await _sessionStore.writeToken(authSession.token);
      await _loadBusiness(authSession.token);
      _status = BusinessAppStatus.signedIn;
      return true;
    } catch (error) {
      _errorMessage = _readableError(error);
      _status = BusinessAppStatus.signedOut;
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _loadBusiness(String token) async {
    final currentUser = await _api.getCurrentUser(token);
    _requireBusinessRole(currentUser.user.role);
    if (currentUser.business.status != 'ACTIVE') {
      throw const BusinessApiException(
          403, 'This business account is not active.');
    }
    _currentUser = currentUser;
    _branches = await _api.getBranches(token);
  }

  void _requireBusinessRole(String role) {
    if (role != 'OWNER' && role != 'BUSINESS_ADMIN') {
      throw const BusinessApiException(
        403,
        'This app is for business owners and business administrators.',
      );
    }
  }

  Future<bool> createBranch({
    required String name,
    required String currency,
    required String timezone,
  }) async {
    final token = await _accessToken();
    if (token == null) return false;
    _setBusy(true);
    _errorMessage = null;
    try {
      final branch = await _api.createBranch(
        token: token,
        name: name,
        currency: currency,
        timezone: timezone,
      );
      _branches = [..._branches, branch];
      return true;
    } catch (error) {
      _errorMessage = _readableError(error);
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<EmployeeInvitation?> inviteEmployee({
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required List<String> branchIds,
  }) async {
    final token = await _accessToken();
    if (token == null) return null;
    _setBusy(true);
    _errorMessage = null;
    try {
      _lastInvitation = await _api.inviteEmployee(
        token: token,
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
        branchIds: branchIds,
      );
      return _lastInvitation;
    } catch (error) {
      _errorMessage = _readableError(error);
      return null;
    } finally {
      _setBusy(false);
    }
  }

  Future<String?> _accessToken() async {
    final token = await _sessionStore.readToken();
    if (token == null || token.isEmpty) {
      _errorMessage = 'Your session has ended. Please sign in again.';
      _status = BusinessAppStatus.signedOut;
      notifyListeners();
      return null;
    }
    return token;
  }

  Future<void> signOut() async {
    await _sessionStore.clear();
    _currentUser = null;
    _branches = const [];
    _lastInvitation = null;
    _errorMessage = null;
    _status = BusinessAppStatus.signedOut;
    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    final token = await _sessionStore.readToken();
    if (token == null || token.isEmpty) {
      _errorMessage = 'Your session has ended. Please sign in again.';
      _status = BusinessAppStatus.signedOut;
      notifyListeners();
      return;
    }
    _setBusy(true);
    _errorMessage = null;
    try {
      await _loadBusiness(token);
    } catch (error) {
      _errorMessage = _readableError(error);
      if (error is BusinessApiException && error.statusCode == 401) {
        await signOut();
      }
    } finally {
      _setBusy(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _readableError(Object error) {
    if (error is BusinessApiException) return error.message;
    if (error is FormatException) {
      return 'The server returned an invalid response.';
    }
    return 'Could not reach ScanFlow. Check your connection and try again.';
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
