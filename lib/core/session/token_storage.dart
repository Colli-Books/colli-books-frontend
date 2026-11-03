import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda o refresh token no Keychain (iOS) / Keystore (Android).
/// O access token NÃO é persistido: vive só em memória no ApiClient.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _refreshKey = 'refresh_token';
  final FlutterSecureStorage _storage;

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _refreshKey, value: token);

  Future<void> clear() => _storage.delete(key: _refreshKey);
}