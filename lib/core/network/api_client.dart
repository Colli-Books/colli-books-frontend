import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException; // remova se for buildar para Flutter Web
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;

import '../config/app_config.dart';
import '../utils/image_sniffer.dart';
import 'api_exception.dart';

/// Quem sabe renovar/encerrar a sessão (implementado pelo SessionManager).
/// Fica aqui para o ApiClient não depender de classes de sessão (evita ciclo).
abstract interface class SessionRefresher {
  /// Tenta renovar o par de tokens. `true` se o access token novo já foi
  /// aplicado no ApiClient; `false` se não foi possível renovar.
  Future<bool> refresh();

  /// Descarta a sessão (tokens + notificação para voltar ao login).
  Future<void> expire();
}

/// Cliente HTTP centralizado para consumo da API do Colli Books.
/// Segue os padrões descritos em 'Contratos API.md'.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;
  String? _accessToken;

  /// Injetado pelo SessionManager. Se nulo, 401 apenas sobe como erro.
  SessionRefresher? refresher;

  /// Atualiza o token Bearer em memória.
  void setAccessToken(String? token) => _accessToken = token;

  String? get accessToken => _accessToken;

  // ---------------------------------------------------------------------------
  // Construção de requisição
  // ---------------------------------------------------------------------------

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final hasPrefix = _baseUrl.endsWith(AppConfig.apiPrefix);
    final prefix = hasPrefix ? '' : AppConfig.apiPrefix;
    final uri = Uri.parse('$_baseUrl$prefix$cleanPath');

    if (queryParameters == null || queryParameters.isEmpty) return uri;

    // Lista vira parâmetro repetido (`theme_ids=1&theme_ids=2`); lista vazia é omitida.
    final queryMap = <String, dynamic>{};
    queryParameters.forEach((key, value) {
      if (value is Iterable) {
        final values = [for (final v in value) if (v != null) v.toString()];
        if (values.isNotEmpty) queryMap[key] = values;
      } else if (value != null) {
        queryMap[key] = value.toString();
      }
    });
    return uri.replace(queryParameters: queryMap);
  }

  /// [authenticated] = false para rotas públicas (login, refresh, logout,
  /// invites, forgot/reset-password): não envia Authorization.
  Map<String, String> _buildHeaders(
    Map<String, String>? custom,
    bool authenticated,
  ) {
    return <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      if (authenticated && (_accessToken?.isNotEmpty ?? false))
        'Authorization': 'Bearer $_accessToken',
      ...?custom,
    };
  }

  // ---------------------------------------------------------------------------
  // API pública
  // ---------------------------------------------------------------------------

  Future<dynamic> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) => _request(
    () => _client.get(
      _buildUri(path, queryParameters),
      headers: _buildHeaders(headers, authenticated),
    ),
    authenticated: authenticated,
  );

  Future<dynamic> post(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    bool authenticated = true,
  }) => _request(
    () => _client.post(
      _buildUri(path),
      headers: _buildHeaders(headers, authenticated),
      body: body != null ? jsonEncode(body) : null,
    ),
    authenticated: authenticated,
  );

  Future<dynamic> put(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    bool authenticated = true,
  }) => _request(
    () => _client.put(
      _buildUri(path),
      headers: _buildHeaders(headers, authenticated),
      body: body != null ? jsonEncode(body) : null,
    ),
    authenticated: authenticated,
  );

  Future<dynamic> patch(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    bool authenticated = true,
  }) => _request(
    () => _client.patch(
      _buildUri(path),
      headers: _buildHeaders(headers, authenticated),
      body: body != null ? jsonEncode(body) : null,
    ),
    authenticated: authenticated,
  );

  Future<dynamic> delete(
    String path, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) => _request(
    () => _client.delete(
      _buildUri(path),
      headers: _buildHeaders(headers, authenticated),
    ),
    authenticated: authenticated,
  );

  Future<dynamic> sendMultipart(
      String method,
      String path, {
        Map<String, String> fields = const {},
        Map<String, List<String>> repeated = const {},
        Uint8List? coverBytes,
        String? coverFilename,
      }) =>
      _request(
            () async {
          final headers = _buildHeaders(null, true)..remove('Content-Type');
          final req = http.MultipartRequest(method, _buildUri(path))
            ..headers.addAll(headers) // a lib define o Content-Type com boundary
            ..fields.addAll(fields);

          repeated.forEach((key, values) {
            for (final v in values) {
              req.files.add(http.MultipartFile.fromBytes(key, utf8.encode(v)));
            }
          });

          if (coverBytes != null) {
            final isPng = sniffImage(coverBytes) == ImageKind.png;
            req.files.add(http.MultipartFile.fromBytes(
              'cover',
              coverBytes,
              filename: coverFilename ?? (isPng ? 'cover.png' : 'cover.jpg'),
              contentType: MediaType('image', isPng ? 'png' : 'jpeg'),
            ));
          }

          return http.Response.fromStream(await _client.send(req));
        },
        authenticated: true,
        timeout: AppConfig.uploadTimeout,
      );

  // ---------------------------------------------------------------------------
  // Núcleo: envio, refresh com retry único e tradução de erros
  // ---------------------------------------------------------------------------

  /// [send] é reexecutado no retry, então deve montar headers (com o token
  /// atual) e o corpo a cada chamada. Retry é seguro mesmo em POST: um
  /// TOKEN_EXPIRED significa que o servidor rejeitou antes de executar.
  Future<dynamic> _request(
    Future<http.Response> Function() send, {
    required bool authenticated,
    Duration? timeout,
  }) async {
    final limit = timeout ?? AppConfig.requestTimeout;

    try {
      try {
        return _processResponse(await send().timeout(limit));
      } on ApiException catch (e) {
        final r = refresher;
        if (!authenticated || e.statusCode != 401 || r == null) rethrow;

        if (e.code == 'TOKEN_EXPIRED') {
          if (await r.refresh()) {
            // Retry único; um 401 aqui sobe normalmente.
            return _processResponse(await send().timeout(limit));
          }
          rethrow;
        }

        if (e.code == 'TOKEN_INVALID' || e.code == 'UNAUTHENTICATED') {
          await r.expire();
        }
        rethrow;
      }
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException.timeout();
    } on http.ClientException catch (e) {
      throw ApiException.networkError(e.message);
    } on SocketException catch (e) {
      throw ApiException.networkError(e.message);
    }
    // Qualquer outra exceção (ex.: erro de serialização) NÃO é "erro de rede":
    // propaga como bug para aparecer nos logs.
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode == 204) return null;

    dynamic decodedBody;
    if (response.bodyBytes.isNotEmpty) {
      try {
        decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        decodedBody = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    if (decodedBody is Map<String, dynamic>) {
      throw ApiException.fromJson(decodedBody, response.statusCode);
    }

    throw ApiException(
      code: 'HTTP_${response.statusCode}',
      message:
          'Erro HTTP ${response.statusCode}: ${response.reasonPhrase ?? "Falha na requisição"}',
      details: decodedBody,
      statusCode: response.statusCode,
    );
  }
}
