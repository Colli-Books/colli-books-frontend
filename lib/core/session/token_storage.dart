import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda o refresh token no Keychain (iOS) / Keystore (Android).
/// Caso o navegador bloqueie storage (ex.: modo anônimo / WebView de QR Code),
/// mantém fallback em memória para não travar a sessão.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _refreshKey = 'refresh_token';
  final FlutterSecureStorage _storage;
  String? _memoryFallback;

  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: _refreshKey) ?? _memoryFallback;
    } catch (_) {
      return _memoryFallback;
    }
  }

  Future<void> writeRefreshToken(String token) async {
    _memoryFallback = token;
    try {
      await _storage.write(key: _refreshKey, value: token);
    } catch (_) {
      // Ignora falha de WebCrypto/localStorage em navegadores restritos
    }
  }

  Future<void> clear() async {
    _memoryFallback = null;
    try {
      await _storage.delete(key: _refreshKey);
    } catch (_) {
      // Ignora falha em navegadores restritos
    }
  }
}