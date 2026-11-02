import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/session/session_manager.dart';
import '../models/user_model.dart';

class AuthApiService {
  AuthApiService(this._api, this._session);

  final ApiClient _api;
  final SessionManager _session;

  /// POST /auth/login. Erros: INVALID_CREDENTIALS, VALIDATION_ERROR, RATE_LIMITED.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final json = _asMap(await _api.post(
      '/auth/login',
      body: {'email': email.trim(), 'password': password},
      authenticated: false,
    ));
    await _session.start(
      access: json['access_token'] as String,
      refresh: json['refresh_token'] as String,
    );
    return UserModel.fromJson(_asMap(json['user']));
  }

  /// Startup ("manter-me conectado").
  /// - sem sessão salva ou sessão rejeitada pelo servidor -> null (ir ao login)
  /// - falha de rede com sessão salva -> lança ApiException (permite "tentar de novo")
  Future<UserModel?> restoreSession() async {
    if (!await _session.hasStoredSession) return null;

    if (!await _session.refresh()) {
      // Se o servidor rejeitou, a sessão já foi limpa. Se os tokens
      // continuam salvos, foi falha transitória.
      if (await _session.hasStoredSession) {
        throw ApiException.networkError('Não foi possível restaurar a sessão.');
      }
      return null;
    }
    return me();
  }

  /// GET /auth/me.
  Future<UserModel> me() async =>
      UserModel.fromJson(_asMap(await _api.get('/auth/me')));

  /// POST /auth/logout. O estado local é descartado mesmo que a chamada falhe.
  Future<void> logout() async {
    final rt = await _session.refreshToken;
    try {
      if (rt != null) {
        await _api.post(
          '/auth/logout',
          body: {'refresh_token': rt},
          authenticated: false,
        );
      }
    } on ApiException {
      // offline ou erro: segue, o local é limpo no finally
    } finally {
      await _session.expire();
    }
  }

  /// POST /auth/forgot-password. Resposta sempre genérica (202).
  Future<String> forgotPassword(String email) async {
    final json = await _api.post(
      '/auth/forgot-password',
      body: {'email': email.trim()},
      authenticated: false,
    );
    if (json is Map<String, dynamic> && json['message'] is String) {
      return json['message'] as String;
    }
    return 'Se houver uma conta com este e-mail, enviaremos um link de redefinição.';
  }

  /// POST /auth/reset-password. Erros: RESET_TOKEN_INVALID, WEAK_PASSWORD.
  /// Todas as sessões abertas são encerradas pelo servidor.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _api.post(
      '/auth/reset-password',
      body: {'token': token.trim(), 'new_password': newPassword},
      authenticated: false,
    );
    await _session.expire(); // volta ao login
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    throw ApiException.unexpected('Resposta fora do formato esperado.');
  }
}