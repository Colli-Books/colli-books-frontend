import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_helpers.dart';
import '../../../../core/session/session_manager.dart';
import '../../../auth/data/models/user_model.dart';

class InvitesApiService {
  InvitesApiService(this._api, this._session);

  final ApiClient _api;
  final SessionManager _session;

  /// POST /invites/verify: confere o convite sem consumi-lo e devolve o e-mail.
  /// Erros: INVITE_INVALID (404), INVITE_ALREADY_USED (409), INVITE_EXPIRED (410).
  Future<String> verify(String token) async {
    final json = asJsonMap(await _api.post(
      '/invites/verify',
      body: {'token': token},
      authenticated: false,
    ));
    return parseResponse(() => json['email'] as String);
  }

  /// POST /invites/accept: ativa a conta e já devolve a sessão (mesmo formato do login).
  /// Erros: os três de convite + VALIDATION_ERROR / WEAK_PASSWORD (422).
  Future<UserModel> accept({
    required String token,
    required String fullName,
    String? school,
    required String password,
  }) async {
    final json = asJsonMap(await _api.post(
      '/invites/accept',
      body: {
        'token': token,
        'full_name': fullName.trim(),
        if (school != null && school.trim().isNotEmpty) 'school': school.trim(),
        'password': password, // sem trim: espaços podem fazer parte da senha
      },
      authenticated: false,
    ));

    // Interpreta tudo antes de iniciar a sessão: resposta malformada não deixa
    // tokens gravados sem usuário.
    final access = parseResponse(() => json['access_token'] as String);
    final refresh = parseResponse(() => json['refresh_token'] as String);
    final user = parseResponse(() => UserModel.fromJson(asJsonMap(json['user'])));

    await _session.start(access: access, refresh: refresh);
    return user;
  }

  /// POST /invites/resend: se o convite estiver expirado, o servidor manda um novo
  /// link para o e-mail cadastrado. Resposta sempre genérica (202).
  Future<void> resend(String token) => _api.post(
    '/invites/resend',
    body: {'token': token},
    authenticated: false,
  );
}