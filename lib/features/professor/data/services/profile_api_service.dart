import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_helpers.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/interests_model.dart';

class ProfileApiService {
  ProfileApiService(this._api);

  final ApiClient _api;

  /// PATCH /me. Campo ausente = não altera; `school` vazia limpa o valor.
  /// `full_name` não pode ser vazio (422): valide antes na tela.
  Future<UserModel> updateProfile({String? fullName, String? school}) async {
    final json = asJsonMap(await _api.patch('/me', body: {
      if (fullName != null) 'full_name': fullName.trim(),
      if (school != null) 'school': school.trim(),
    }));
    return parseResponse(() => UserModel.fromJson(json));
  }

  /// PUT /me/password. Erros: CURRENT_PASSWORD_INVALID (400), WEAK_PASSWORD (422).
  /// ATENÇÃO: em sucesso o servidor encerra TODAS as sessões, inclusive a atual.
  /// A tela deve avisar e chamar AuthController.logout() em seguida.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.put('/me/password', body: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  /// PUT /me/interests: substituição integral. `[]` limpa aquele tipo de vínculo.
  /// Só chame com o conjunto COMPLETO (ver lacuna 1: não há como ler o atual).
  Future<InterestsModel> updateInterests({
    required List<int> themeIds,
    required List<int> educationLevelIds,
  }) async {
    final json = asJsonMap(await _api.put('/me/interests', body: {
      'theme_ids': themeIds,
      'education_level_ids': educationLevelIds,
    }));
    return parseResponse(() => InterestsModel.fromJson(json));
  }
}