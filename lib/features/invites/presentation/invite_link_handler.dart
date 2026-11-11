import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../auth/presentation/screens/reset_password_screen.dart';
import '../data/invite_token.dart';
import 'screens/accept_invite_screen.dart';

/// Abre as telas certas para os deep links `collibooks://convite` e
/// `collibooks://redefinir-senha` (vindos direto ou pela página https `/abrir`).
class InviteLinkHandler {
  InviteLinkHandler({
    required this._navigatorKey,
    required this._auth,
  });

  final GlobalKey<NavigatorState> _navigatorKey;
  final AuthController _auth;

  StreamSubscription<Uri>? _sub;
  String? _openToken; // link com a tela aberta: ignora o mesmo link entregue duas vezes

  void start() {
    _sub ??= AppLinks().uriLinkStream.listen(
      _onUri,
      // Nunca logar o link: o token é um segredo de uso único.
      onError: (Object e) => debugPrint('Falha ao ler deep link: ${e.runtimeType}'),
    );
  }

  void dispose() => _sub?.cancel();

  Future<void> _onUri(Uri uri) async {
    final link = appLinkFromUri(uri);
    if (link == null || link.token == _openToken) return;

    _openToken = link.token;
    try {
      await _open(link);
    } finally {
      _openToken = null;
    }
  }

  Future<void> _open(AppLink link) async {
    await _waitForAuthResolved();
    await WidgetsBinding.instance.endOfFrame; // garante o Navigator montado

    final nav = _navigatorKey.currentState;
    final context = _navigatorKey.currentContext;
    if (nav == null || context == null) return;

    if (_auth.status == AuthStatus.authenticated && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            link.kind == AppLinkKind.invite
                ? 'Você já está conectado. Saia da conta para aceitar um convite.'
                : 'Você já está conectado. Saia da conta para redefinir a senha pelo link.',
          ),
        ),
      );
      return;
    }

    // Completa quando a tela é fechada.
    await nav.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => switch (link.kind) {
          AppLinkKind.invite => AcceptInviteScreen(token: link.token),
          AppLinkKind.passwordReset => ResetPasswordScreen(token: link.token),
        },
      ),
    );
  }

  Future<void> _waitForAuthResolved() {
    if (_auth.status != AuthStatus.unknown) return Future.value();
    final completer = Completer<void>();
    void listener() {
      if (_auth.status != AuthStatus.unknown) {
        _auth.removeListener(listener);
        completer.complete();
      }
    }

    _auth.addListener(listener);
    return completer.future;
  }
}