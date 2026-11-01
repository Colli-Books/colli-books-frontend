import 'api_exception.dart';

List<dynamic> asJsonList(dynamic value) {
  if (value is List) return value;
  throw ApiException.unexpected('Resposta fora do formato esperado.');
}