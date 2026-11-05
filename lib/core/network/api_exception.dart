// lib/core/network/api_exception.dart
//
// Sem imports: a classe usa apenas tipos do núcleo do Dart.
// (O nome do arquivo é `api_exception.dart`, no singular, porque é assim
// que o api_client.dart o importa. Se o seu se chama `api_exceptions.dart`,
// renomeie o arquivo ou ajuste o import.)

/// Exceção padronizada de resposta de erro da API do Colli Books.
/// Segue a Seção 4 de 'Contratos API.md'.
///
/// Também representa falhas que nunca chegaram ao servidor (rede, timeout),
/// com `statusCode == 0`. Use [isNetworkError] para distingui-las.
class ApiException implements Exception {
  /// Código estável de máquina (ex: INVALID_CREDENTIALS, VALIDATION_ERROR,
  /// RATE_LIMITED). A UI deve decidir o comportamento por ele, nunca pela
  /// [message].
  final String code;

  /// Mensagem amigável sugerida em português (pode mudar entre versões).
  final String message;

  /// Detalhes adicionais estruturados (ex: lista de validações campo a campo
  /// em 422 VALIDATION_ERROR).
  final dynamic details;

  /// Código de status HTTP da resposta (ex: 400, 401, 404, 422, 429).
  /// `0` quando a requisição não obteve resposta do servidor.
  final int statusCode;

  const ApiException({
    required this.code,
    required this.message,
    this.details,
    required this.statusCode,
  });

  /// Monta a exceção a partir do corpo de erro da API: `{code, message, details}`.
  factory ApiException.fromJson(Map<String, dynamic> json, int statusCode) {
    return ApiException(
      code: json['code']?.toString() ?? 'HTTP_ERROR',
      message: json['message']?.toString() ?? 'Ocorreu um erro na requisição.',
      details: json['details'],
      statusCode: statusCode,
    );
  }

  /// Sem conexão, DNS, conexão recusada etc.
  factory ApiException.networkError(String detail) {
    return ApiException(
      code: 'NETWORK_ERROR',
      message: 'Não foi possível conectar ao servidor. Verifique sua conexão.',
      details: detail,
      statusCode: 0,
    );
  }

  /// O servidor não respondeu dentro do limite de tempo.
  factory ApiException.timeout() {
    return const ApiException(
      code: 'TIMEOUT',
      message: 'O servidor demorou muito para responder. Tente novamente.',
      statusCode: 0,
    );
  }

  /// Resposta recebida, mas num formato que o app não soube interpretar.
  factory ApiException.unexpected(String detail) {
    return ApiException(
      code: 'UNEXPECTED_ERROR',
      message: 'Ocorreu um erro inesperado ao processar a resposta.',
      details: detail,
      statusCode: 500,
    );
  }

  /// `true` para falhas sem resposta do servidor (rede e timeout).
  /// Nesses casos o fluxo correto é "sem conexão" + botão de tentar de novo.
  bool get isNetworkError => statusCode == 0;

  /// Erros de validação campo a campo, para destacar formulários (US15).
  ///
  /// Em 422 VALIDATION_ERROR: [{loc: ["body","email"], msg: "..."}].
  /// Usa o primeiro nome de campo de `loc` (ignora body/query/path e índices).
  /// Se houver vários erros para o mesmo campo, vale o primeiro.
  Map<String, String> get fieldErrors {
    final d = details;
    if (d is! List) return const {};
    final out = <String, String>{};
    for (final e in d.whereType<Map<String, dynamic>>()) {
      final loc = e['loc'];
      if (loc is! List) continue;
      final field = loc
          .whereType<String>()
          .where((s) => s != 'body' && s != 'query' && s != 'path')
          .firstOrNull;
      if (field != null) out.putIfAbsent(field, () => '${e['msg']}');
    }
    return out;
  }

  @override
  String toString() => 'ApiException [$code] (HTTP $statusCode): $message';
}