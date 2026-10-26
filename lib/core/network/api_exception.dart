/// Exceção padronizada de resposta de erro da API do Colli Books.
/// Segue rigorosamente a Seção 4 de 'Contratos API.md'.
class ApiException implements Exception {
  /// Código estável de máquina (ex: INVALID_CREDENTIALS, VALIDATION_ERROR, RATE_LIMITED)
  final String code;

  /// Mensagem amigável sugerida em português
  final String message;

  /// Detalhes adicionais estruturados (ex: lista de validações campo a campo)
  final dynamic details;

  /// Código de status HTTP da resposta (ex: 400, 401, 404, 422, 429)
  final int statusCode;

  const ApiException({
    required this.code,
    required this.message,
    this.details,
    required this.statusCode,
  });

  factory ApiException.fromJson(Map<String, dynamic> json, int statusCode) {
    return ApiException(
      code: json['code']?.toString() ?? 'HTTP_ERROR',
      message: json['message']?.toString() ?? 'Ocorreu um erro na requisição.',
      details: json['details'],
      statusCode: statusCode,
    );
  }

  factory ApiException.networkError(String detail) {
    return ApiException(
      code: 'NETWORK_ERROR',
      message: 'Não foi possível conectar ao servidor. Verifique sua conexão.',
      details: detail,
      statusCode: 0,
    );
  }

  factory ApiException.unexpected(String detail) {
    return ApiException(
      code: 'UNEXPECTED_ERROR',
      message: 'Ocorreu um erro inesperado ao processar a resposta.',
      details: detail,
      statusCode: 500,
    );
  }

  @override
  String toString() => 'ApiException [$code] (HTTP $statusCode): $message';
}
