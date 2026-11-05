import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../data/invite_token.dart';
import 'screens/accept_invite_screen.dart';

class InviteLinkHandler {
  InviteLinkHandler({
    required this._navigatorKey,
    required this._auth,
  });

  final GlobalKey<NavigatorState> _navigatorKey;
  final AuthController _auth;

  StreamSubscription<Uri>? _sub;
  String? _openToken; // convite com a tela aberta: ignora o mesmo link entregue duas vezes

  void start() {
    _sub ??= AppLinks().uriLinkStream.listen(
      _onUri,
      // Nunca logar o link: o token é um segredo de uso único.
      onError: (Object e) => debugPrint('Falha ao ler deep link: ${e.runtimeType}'),
    );
  }

  void dispose() => _sub?.cancel();

  Future<void> _onUri(Uri uri) async {
    final token = inviteTokenFromUri(uri);
    if (token == null || token == _openToken) return;

    _openToken = token;
    try {
      await _open(token);
    } finally {
      _openToken = null;
    }
  }

  Future<void> _open(String token) async {
    await _waitForAuthResolved();
    await WidgetsBinding.instance.endOfFrame; // garante o Navigator montado

    final nav = _navigatorKey.currentState;
    final context = _navigatorKey.currentContext;
    if (nav == null || context == null) return;

    if (_auth.status == AuthStatus.authenticated && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Você já está conectado. Saia da conta para aceitar um convite.'),
        ),
      );
      return;
    }

    // Completa quando a tela é fechada.
    await nav.push<void>(
      MaterialPageRoute<void>(builder: (_) => AcceptInviteScreen(token: token)),
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