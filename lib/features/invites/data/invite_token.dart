const _scheme = 'collibooks';
const _inviteHost = 'convite';
const _resetHost = 'redefinir-senha';

/// Destino de um deep link `collibooks://...` que o app sabe abrir.
enum AppLinkKind { invite, passwordReset }

/// Deep link reconhecido: o destino e o token (segredo de uso único).
typedef AppLink = ({AppLinkKind kind, String token});

/// Lê `collibooks://convite?token=...` ou `collibooks://redefinir-senha?token=...`.
/// Retorna null para qualquer outro link ou token vazio/malformado.
AppLink? appLinkFromUri(Uri uri) {
  if (uri.scheme != _scheme) return null;
  final kind = switch (uri.host) {
    _inviteHost => AppLinkKind.invite,
    _resetHost => AppLinkKind.passwordReset,
    _ => null,
  };
  final token = _clean(uri.queryParameters['token']);
  if (kind == null || token == null) return null;
  return (kind: kind, token: token);
}

/// Token de um deep link `collibooks://convite?token=...`; null se não for um convite.
String? inviteTokenFromUri(Uri uri) {
  final link = appLinkFromUri(uri);
  return link?.kind == AppLinkKind.invite ? link!.token : null;
}

/// Aceita o que a pessoa colar na tela "Tenho um convite": o código puro ou o link inteiro
/// (`collibooks://convite?token=...` ou o link https do e-mail, `.../abrir/convite?token=...`).
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
