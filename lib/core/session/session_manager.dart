import 'dart:async';

import '../network/api_client.dart';
import '../network/api_exception.dart';
import 'token_storage.dart';

class SessionManager implements SessionRefresher {
  SessionManager(this._api, this._storage) {
    _api.refresher = this; // liga o ApiClient ao refresh automático
  }

  final ApiClient _api;
  final TokenStorage _storage;

  Future<bool>? _inflight;
  final _expired = StreamController<void>.broadcast();

  /// Emite quando a sessão foi encerrada (refresh rejeitado, token inválido, logout).
  Stream<void> get onExpired => _expired.stream;

  Future<String?> get refreshToken => _storage.readRefreshToken();

  Future<bool> get hasStoredSession async =>
      (await _storage.readRefreshToken()) != null;

  /// Chamar após login e invites/accept (mesmo formato de resposta).
  Future<void> start({required String access, required String refresh}) async {
    await _storage.writeRefreshToken(refresh);
    _api.setAccessToken(access);
  }

  /// Single-flight: chamadas simultâneas compartilham a mesma Future.
  @override
  Future<bool> refresh() =>
      _inflight ??= _doRefresh().whenComplete(() => _inflight = null);

  Future<bool> _doRefresh() async {
    final rt = await _storage.readRefreshToken();
    if (rt == null) return false;
    try {
      final json = await _api.post(
        '/auth/refresh',
        body: {'refresh_token': rt},
        authenticated: false,
      ) as Map<String, dynamic>;

      // Persistir o refresh novo ANTES de qualquer outra coisa:
      // o antigo já foi revogado no servidor.
      await _storage.writeRefreshToken(json['refresh_token'] as String);
      _api.setAccessToken(json['access_token'] as String);
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 401) await expire(); // rejeição definitiva
      return false; // rede/timeout/5xx: mantém os tokens
    }
  }

  @override
  Future<void> expire() async {
    _api.setAccessToken(null);
    await _storage.clear();
    _expired.add(null);
  }
}