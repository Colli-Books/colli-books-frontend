// Configuração dos testes E2E, lida de `--dart-define`.
///
/// Obrigatórias:
///   --dart-define=API_BASE_URL=http://10.0.2.2:8000      (lida pelo AppConfig do app)
///   --dart-define=E2E_ADMIN_EMAIL=admin@...              (admin criado por seed no backend de teste)
///   --dart-define=E2E_ADMIN_PASSWORD=...
///
/// Opcionais (sem elas, os testes correspondentes são PULADOS):
///   E2E_EXPIRED_INVITE_TOKEN   token de um convite já expirado (US02)
///   E2E_MAILPIT_URL            URL de um coletor de e-mails Mailpit (US04: redefinição completa)
///   E2E_ACCESS_TTL_SECONDS     validade do access token configurada no backend de teste (renovação de sessão)
class E2eEnv {
  static const adminEmail = String.fromEnvironment('E2E_ADMIN_EMAIL');
  static const adminPassword = String.fromEnvironment('E2E_ADMIN_PASSWORD');

  static const expiredInviteToken = String.fromEnvironment('E2E_EXPIRED_INVITE_TOKEN');
  static const mailpitUrl = String.fromEnvironment('E2E_MAILPIT_URL');
  static const accessTtlSeconds = int.fromEnvironment('E2E_ACCESS_TTL_SECONDS');

  /// Falha cedo, com mensagem clara, em vez de um erro obscuro de login no meio do teste.
  static void ensure() {
    if (adminEmail.isEmpty || adminPassword.isEmpty) {
      throw StateError(
        'Defina --dart-define=E2E_ADMIN_EMAIL=... e --dart-define=E2E_ADMIN_PASSWORD=... '
            '(admin criado por seed no backend de teste).',
      );
    }
  }
}
