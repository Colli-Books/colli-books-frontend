import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';

/// Serviço para operações de autenticação e recuperação de senha.
/// Implementa as especificações da Seção 7.1 do 'Contratos API.md'.
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Solicita o envio de link de recuperação de senha por e-mail.
  /// Endpoint: POST /api/v1/auth/forgot-password
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        '/auth/forgot-password',
        body: {'email': email.trim()},
      );

      if (response is Map<String, dynamic> && response['message'] != null) {
        return response['message'] as String;
      }
      return 'Se houver uma conta com este e-mail, enviaremos um link de redefinição.';
    } on ApiException {
      rethrow;
    } catch (e) {
      // Fallback gracioso para modo offline / desenvolvimento
      return 'Solicitação de recuperação processada. Se o e-mail estiver cadastrado, as instruções serão enviadas.';
    }
  }

  /// Redefine a senha com o token recebido pelo link ou e-mail.
  /// Endpoint: POST /api/v1/auth/reset-password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/auth/reset-password',
      body: {
        'token': token.trim(),
        'new_password': newPassword,
      },
    );
  }

  /// Realiza login com e-mail e senha.
  /// Endpoint: POST /api/v1/auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {
        'email': email.trim(),
        'password': password,
      },
    );
    if (response is Map<String, dynamic>) {
      final token = response['access_token'] as String?;
      if (token != null) {
        _apiClient.setAccessToken(token);
      }
      return response;
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Resposta inesperada do servidor ao realizar login.',
      statusCode: 500,
    );
  }
}
