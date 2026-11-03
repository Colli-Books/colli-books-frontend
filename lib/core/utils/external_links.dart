import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Só aceita http(s) com host: links podem vir de texto livre digitado pela editora.
Uri? safeHttpUri(String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return null;
  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasAuthority) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  return uri;
}

Future<void> openExternalLink(BuildContext context, String? raw) async {
  final messenger = ScaffoldMessenger.of(context); // antes de qualquer await
  final uri = safeHttpUri(raw);
  if (uri == null) {
    messenger.showSnackBar(const SnackBar(content: Text('Este link é inválido.')));
    return;
  }
  try {
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
  } catch (e) {
    debugPrint('Falha ao abrir $uri: $e');
  }
  messenger.showSnackBar(
    const SnackBar(content: Text('Não foi possível abrir o link neste aparelho.')),
  );
}