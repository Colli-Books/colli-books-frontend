import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/session/session_manager.dart';
import 'core/session/token_storage.dart';
import 'features/admin/presentation/screens/admin_home_screen.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/data/services/auth_api_service.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/professor/presentation/screens/professor_home_screen.dart';
import 'features/admin/data/services/admin_api_service.dart';
import 'features/catalogo/data/services/catalog_api_service.dart';
import 'features/catalogo/presentation/controllers/saved_books_controller.dart';
import 'features/professor/data/services/profile_api_service.dart';
import 'features/invites/data/services/invites_api_service.dart';
import 'features/invites/presentation/invite_link_handler.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // UMA instância de ApiClient para o app inteiro: o access token vive nela.
  final api = ApiClient();
  final session = SessionManager(api, TokenStorage());
  final authService = AuthApiService(api, session);
  final auth = AuthController(authService, session)..restoreSession();
  final adminService = AdminApiService(api);
  final catalogService = CatalogApiService(api);
  final savedBooks = SavedBooksController(catalogService);
  final profileService = ProfileApiService(api);
  final invitesService = InvitesApiService(api, session);

  // Sessão encerrada em qualquer ponto: desempilha telas até a raiz (AuthGate).
  auth.addListener(() {
    if (auth.status == AuthStatus.unauthenticated) {
      savedBooks.clear();
      navigatorKey.currentState?.popUntil((r) => r.isFirst);
    }
  });
  InviteLinkHandler(navigatorKey: navigatorKey, auth: auth).start();

  runApp(MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: api),
      Provider<AuthApiService>.value(value: authService),
      Provider<AdminApiService>.value(value: adminService),
      Provider<CatalogApiService>.value(value: catalogService),
      ChangeNotifierProvider<AuthController>.value(value: auth),
      Provider<ProfileApiService>.value(value: profileService),
      ChangeNotifierProvider<SavedBooksController>.value(value: savedBooks),
      Provider<InvitesApiService>.value(value: invitesService),
    ],
    child: const ColliBooksApp(),
  ));
}

class ColliBooksApp extends StatelessWidget {
  const ColliBooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Colli Books',
      // theme: ...  (o seu atual)
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return switch (auth.status) {
      AuthStatus.unknown => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.restoreFailed => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Não foi possível restaurar sua sessão.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: auth.restoreSession,
                child: const Text('Tentar de novo'),
              ),
            ],
          ),
        ),
      ),
      AuthStatus.unauthenticated => const LoginScreen(),
    // O papel vem do servidor (user.role), não do e-mail.
      AuthStatus.authenticated => auth.user!.role == UserRole.admin
          ? const AdminHomeScreen()
          : const ProfessorHomeScreen(),
    };
  }
}