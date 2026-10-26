import 'package:flutter/foundation.dart';

/// Configurações gerais e de ambiente da aplicação.
/// Segue a convenção de Base URL descrita em Contratos API.md (seção 2).
class AppConfig {
  /// Base URL da API do backend FastAPI.
  /// Pode ser sobrescrita em tempo de compilação via:
  /// `--dart-define=API_BASE_URL=https://sua-api.com`
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000'; // IP padrão do host no emulador Android
    }
    return 'http://localhost:8000';
  }

  /// Prefixo oficial dos endpoints REST v1
  static const String apiPrefix = '/api/v1';

  /// Timeout padrão para requisições de leitura/escrita
  static const Duration requestTimeout = Duration(seconds: 10);
}
