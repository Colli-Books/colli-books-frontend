import 'dart:convert';

import 'package:http/http.dart' as http;

import 'e2e_env.dart';

/// Lê o e-mail de redefinição de senha num coletor de e-mails (Mailpit).
///
/// ATENÇÃO: não foi verificado contra o seu ambiente. Depende de:
///   1. o backend de teste enviar e-mails por SMTP para o Mailpit;
///   2. o formato do link do e-mail conter `token=<valor>` (ajuste a RegExp se for outro);
///   3. a API REST do Mailpit (`/api/v1/search` e `/api/v1/message/{id}`): confira na documentação
///      da versão que você usa.
/// Sem E2E_MAILPIT_URL, os testes que usam isto são pulados.
class E2eMail {
  /// Token do e-mail mais recente enviado para [email]. Tenta por ~10 s (o envio é assíncrono).
  static Future<String?> latestToken(String email) async {
    final base = E2eEnv.mailpitUrl;
    if (base.isEmpty) return null;

    for (var attempt = 0; attempt < 10; attempt++) {
      final token = await _tryRead(base, email);
      if (token != null) return token;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return null;
  }

  static Future<String?> _tryRead(String base, String email) async {
    final search = await http.get(
      Uri.parse('$base/api/v1/search?query=${Uri.encodeQueryComponent('to:$email')}'),
    );
    if (search.statusCode != 200) return null;

    final data = jsonDecode(search.body) as Map<String, dynamic>;
    final messages = (data['messages'] as List?) ?? const [];
    if (messages.isEmpty) return null;

    final id = (messages.first as Map<String, dynamic>)['ID'];
    final message = await http.get(Uri.parse('$base/api/v1/message/$id'));
    if (message.statusCode != 200) return null;

    final body = jsonDecode(message.body) as Map<String, dynamic>;
    final text = '${body['Text'] ?? ''} ${body['HTML'] ?? ''}';
    final match = RegExp(r'token=([A-Za-z0-9_\-\.~%]+)').firstMatch(text);
    return match == null ? null : Uri.decodeComponent(match.group(1)!);
  }
}