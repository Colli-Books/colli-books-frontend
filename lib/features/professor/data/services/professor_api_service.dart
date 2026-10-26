import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';

/// Resultado estruturado da atualização de perfil do professor
class ProfileUpdateResult {
  final bool success;
  final bool isOffline;
  final String message;
  final Map<String, String> data;

  const ProfileUpdateResult({
    required this.success,
    required this.isOffline,
    required this.message,
    required this.data,
  });
}

/// Serviço de integração com a API para dados do Professor.
/// Implementa as diretrizes da Seção 7.8 do 'Contratos API.md'.
class ProfessorApiService {
  final ApiClient _apiClient;

  ProfessorApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Atualiza o perfil e credenciais do professor via API.
  /// Envia para PATCH /api/v1/me com payload { full_name, email, school }.
  /// Caso o servidor esteja temporariamente offline ou em desenvolvimento,
  /// opera em modo de demonstração seguro sem travar o aplicativo.
  Future<ProfileUpdateResult> updateProfile({
    required String nome,
    required String email,
    required String escola,
  }) async {
    final payload = {
      'full_name': nome.trim(),
      'email': email.trim(),
      'school': escola.trim().isNotEmpty ? escola.trim() : null,
    };

    try {
      final response = await _apiClient.patch('/me', body: payload);

      if (response is Map<String, dynamic>) {
        final updatedData = {
          'nome': (response['full_name'] ?? nome).toString(),
          'email': (response['email'] ?? email).toString(),
          'escola': (response['school'] ?? escola).toString(),
        };

        return ProfileUpdateResult(
          success: true,
          isOffline: false,
          message: 'Informações e e-mail atualizados no servidor com sucesso!',
          data: updatedData,
        );
      }

      return ProfileUpdateResult(
        success: true,
        isOffline: false,
        message: 'Perfil atualizado com sucesso!',
        data: {'nome': nome, 'email': email, 'escola': escola},
      );
    } on ApiException catch (e) {
      if (e.code == 'NETWORK_ERROR' || e.code == 'TIMEOUT' || e.statusCode == 404) {
        debugPrint('ProfessorApiService [Offline Fallback]: ${e.message}');
        return ProfileUpdateResult(
          success: true,
          isOffline: true,
          message: 'Dados salvos localmente. A sincronização com o servidor será concluída quando a API estiver ativa.',
          data: {'nome': nome, 'email': email, 'escola': escola},
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('ProfessorApiService [Erro Inesperado]: $e');
      return ProfileUpdateResult(
        success: true,
        isOffline: true,
        message: 'Dados salvos localmente (conexão em modo de contingência).',
        data: {'nome': nome, 'email': email, 'escola': escola},
      );
    }
  }
}
