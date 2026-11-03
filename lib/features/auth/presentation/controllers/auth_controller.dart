import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/session/session_manager.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_api_service.dart';

enum AuthStatus {
  unknown,         // restaurando sessão (splash)
  authenticated,
  unauthenticated,
  restoreFailed,   // havia sessão salva, mas não deu para restaurar (rede/servidor)
}

class AuthController extends ChangeNotifier {
  AuthController(this._service, SessionManager session) {
    _sub = session.onExpired.listen((_) => _setUnauthenticated());
  }

  final AuthApiService _service;
  late final StreamSubscription<void> _sub;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;

  AuthStatus get status => _status;
  UserModel? get user => _user;

  Future<void> restoreSession() async {
    _status = AuthStatus.unknown;
    notifyListeners();
    try {
      final user = await _service.restoreSession();
      _user = user;
      _status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    } on ApiException catch (e) {
      _user = null;
      _status = e.isNetworkError
          ? AuthStatus.restoreFailed
          : AuthStatus.unauthenticated;
    } catch (e, st) {
      // bug inesperado: não deixar o app preso na splash
      debugPrint('restoreSession falhou: $e\n$st');
      _user = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Lança ApiException em caso de erro (a tela decide a mensagem pelo `code`).
  Future<void> login(String email, String password) async {
    final user = await _service.login(email: email, password: password);
    _user = user;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.logout(); // expire() dispara _setUnauthenticated via onExpired
    _setUnauthenticated();
  }

  void _setUnauthenticated() {
    if (_status == AuthStatus.unauthenticated) return;
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void updateUser(UserModel user) {
    if (_status != AuthStatus.authenticated) return;
    _user = user;
    notifyListeners();
  }

  /// Adota uma sessão iniciada fora do login (ex.: aceite de convite).
  void adoptSession(UserModel user) {
    _user = user;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }
}