import 'api_exception.dart';

/// Garante que o corpo da resposta é um objeto JSON.
Map<String, dynamic> asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  throw ApiException.unexpected('Resposta fora do formato esperado.');
}

/// Garante que o corpo da resposta é uma lista JSON.
List<dynamic> asJsonList(dynamic value) {
  if (value is List) return value;
  throw ApiException.unexpected('Resposta fora do formato esperado.');
}

/// Executa o parsing e converte falhas de formato em ApiException,
/// para a UI tratar tudo num único tipo de erro.
T parseResponse<T>(T Function() parse) {
  try {
    return parse();
  } on ApiException {
    rethrow;
  } on TypeError catch (e) {
    throw ApiException.unexpected(e.toString());
  } on FormatException catch (e) {
    throw ApiException.unexpected(e.message);
  }
}