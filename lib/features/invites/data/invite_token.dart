const _scheme = 'collibooks';
const _host = 'convite';

/// Token de um deep link `collibooks://convite?token=...`; null se não for um convite.
String? inviteTokenFromUri(Uri uri) {
  if (uri.scheme != _scheme || uri.host != _host) return null;
  return _clean(uri.queryParameters['token']);
}

/// Aceita o que a pessoa colar na tela "Tenho um convite": o código puro ou o link inteiro.
String? extractInviteToken(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;

  if (text.contains('://')) {
    final uri = Uri.tryParse(text);
    return uri == null ? null : _clean(uri.queryParameters['token']);
  }
  return _clean(text);
}

String? _clean(String? raw) {
  final t = raw?.trim() ?? '';
  if (t.isEmpty || t.contains(RegExp(r'\s'))) return null;
  return t;
}