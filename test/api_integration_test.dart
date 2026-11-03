import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:colli_books_frontend/core/network/api_client.dart';
import 'package:colli_books_frontend/core/network/api_exception.dart';
import 'package:colli_books_frontend/features/auth/data/services/auth_api_service.dart';
import 'package:colli_books_frontend/features/professor/data/services/professor_api_service.dart';

void main() {
  group('Testes de Integração - Camada de Rede e Contratos API', () {
    test('ApiClient executa requisição GET com cabeçalhos e decodifica JSON', () async {
      final mockHttpClient = MockClient((request) async {
        expect(request.url.path, endsWith('/livros'));
        expect(request.headers['Content-Type'], contains('application/json'));
        return http.Response(
          jsonEncode({
            'items': [
              {'id': 1, 'titulo': 'O Segredo de Aurora'},
            ],
            'total': 1,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'http://localhost:8000/api/v1',
        httpClient: mockHttpClient,
      );

      final result = await apiClient.get('/livros');
      expect(result, isA<Map<String, dynamic>>());
      expect((result as Map<String, dynamic>)['total'], equals(1));
    });

    test('ApiClient converte erro padronizado do backend em ApiException', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': 'EMAIL_ALREADY_EXISTS',
            'message': 'O e-mail informado já está em uso por outro usuário.',
            'details': {'field': 'email'},
          }),
          409,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'http://localhost:8000/api/v1',
        httpClient: mockHttpClient,
      );

      expect(
        () async => await apiClient.patch('/me', body: {'email': 'ja.existe@escola.com'}),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'EMAIL_ALREADY_EXISTS')),
      );
    });

    test('AuthApiService: forgotPassword envia payload correto para /auth/forgot-password', () async {
      final mockHttpClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, endsWith('/auth/forgot-password'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], equals('prof.teste@escola.com.br'));

        return http.Response(
          jsonEncode({'message': 'Se o e-mail existir, um link de recuperação será enviado.'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(baseUrl: 'http://localhost:8000/api/v1', httpClient: mockHttpClient);
      final authService = AuthApiService(apiClient: apiClient);

      final message = await authService.forgotPassword('prof.teste@escola.com.br');
      expect(message, contains('link de recuperação'));
    });

    test('AuthApiService: resetPassword envia token e nova senha para /auth/reset-password', () async {
      final mockHttpClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, endsWith('/auth/reset-password'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['token'], equals('TOKEN-123456'));
        expect(body['new_password'], equals('NovaSenha2026'));

        return http.Response(
          jsonEncode({'message': 'Senha alterada com sucesso.'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(baseUrl: 'http://localhost:8000/api/v1', httpClient: mockHttpClient);
      final authService = AuthApiService(apiClient: apiClient);

      await authService.resetPassword(token: 'TOKEN-123456', newPassword: 'NovaSenha2026');
    });

    test('ProfessorApiService: updateProfile atualiza nome, email e escola via PATCH /me', () async {
      final mockHttpClient = MockClient((request) async {
        expect(request.method, equals('PATCH'));
        expect(request.url.path, endsWith('/me'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['full_name'], equals('Professora Helena'));
        expect(body['email'], equals('helena@colegio.com'));
        expect(body['school'], equals('Colégio Santa Clara'));

        return http.Response(
          jsonEncode({
            'full_name': 'Professora Helena',
            'email': 'helena@colegio.com',
            'school': 'Colégio Santa Clara',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(baseUrl: 'http://localhost:8000/api/v1', httpClient: mockHttpClient);
      final professorService = ProfessorApiService(apiClient: apiClient);

      final result = await professorService.updateProfile(
        nome: 'Professora Helena',
        email: 'helena@colegio.com',
        escola: 'Colégio Santa Clara',
      );

      expect(result.success, isTrue);
      expect(result.isOffline, isFalse);
      expect(result.data['email'], equals('helena@colegio.com'));
    });

    test('ProfessorApiService: ativa fallback de contingência quando servidor está temporariamente offline', () async {
      final mockHttpClient = MockClient((request) async {
        throw http.ClientException('Falha de conexão com o servidor local.');
      });

      final apiClient = ApiClient(baseUrl: 'http://localhost:8000/api/v1', httpClient: mockHttpClient);
      final professorService = ProfessorApiService(apiClient: apiClient);

      final result = await professorService.updateProfile(
        nome: 'Marcos Silva',
        email: 'marcos@escola.com',
        escola: 'Escola Modelo',
      );

      // Não quebra a experiência do usuário, mantendo os dados localmente
      expect(result.success, isTrue);
      expect(result.isOffline, isTrue);
      expect(result.data['nome'], equals('Marcos Silva'));
    });
  });
}
