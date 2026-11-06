import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class PosSessionStore {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clear();
}

class SecurePosSessionStore implements PosSessionStore {
  SecurePosSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'scanflow.pos.access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _tokenKey);
}
