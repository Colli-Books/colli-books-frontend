import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/session/session_manager.dart';
import 'core/session/token_storage.dart';
import 'features/admin/data/services/admin_api_service.dart';
import 'features/admin/presentation/screens/admin_home_screen.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/data/services/auth_api_service.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/catalogo/data/services/catalog_api_service.dart';
import 'features/catalogo/presentation/controllers/saved_books_controller.dart';
import 'features/invites/data/services/invites_api_service.dart';
import 'features/invites/presentation/invite_link_handler.dart';
import 'features/professor/data/services/profile_api_service.dart';
import 'features/professor/presentation/screens/professor_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};

    final uri = Uri.tryParse(AppConfig.apiBaseUrl);
    if (uri == null || uri.scheme != 'https') {
      throw StateError(
        'Build de release exige API_BASE_URL com https:// (recebido: ${AppConfig.apiBaseUrl}).',
      );
    }
  }
  runApp(const ColliBooksRoot());
}

/// Raiz do app. Toda a composição (serviços, controllers, deep link) vive no State:
/// - os testes E2E sobem uma instância nova a cada teste (`pumpWidget(const ColliBooksRoot())`);
/// - nada fica em variável global, então nada vaza de um teste (ou de um login) para o próximo;
/// - `dispose` cancela o deep link e os controllers.
class ColliBooksRoot extends StatefulWidget {
  const ColliBooksRoot({super.key, this.enableDeepLinks = true});

  /// Os testes desligam quando não precisam (cada assinatura do app_links é um listener a mais).
  final bool enableDeepLinks;

  @override
  State<ColliBooksRoot> createState() => _ColliBooksRootState();
}

class _ColliBooksRootState extends State<ColliBooksRoot> {
  // Por instância (e não global): uma GlobalKey reaproveitada entre instâncias
  // poderia reaproveitar o Navigator (e as rotas) da instância anterior.
  final _navigatorKey = GlobalKey<NavigatorState>();

  late final ApiClient _api;
  late final AuthApiService _authService;
  late final AdminApiService _adminService;
  late final CatalogApiService _catalogService;
  late final ProfileApiService _profileService;
  late final InvitesApiService _invitesService;
  late final AuthController _auth;
  late final SavedBooksController _savedBooks;
  InviteLinkHandler? _links;

  @override
  void initState() {
    super.initState();

    // UMA instância de ApiClient por app: o access token vive nela.
    _api = ApiClient();
    final session = SessionManager(_api, TokenStorage());

    _authService = AuthApiService(_api, session);
    _adminService = AdminApiService(_api);
    _catalogService = CatalogApiService(_api);
    _profileService = ProfileApiService(_api);
    _invitesService = InvitesApiService(_api, session);

    _savedBooks = SavedBooksController(_catalogService);
    _auth = AuthController(_authService, session)..restoreSession();
    _auth.addListener(_onAuthChanged);

    if (widget.enableDeepLinks) {
      _links = InviteLinkHandler(navigatorKey: _navigatorKey, auth: _auth)..start();
    }
  }

  /// Sessão encerrada em qualquer ponto: limpa a seleção e desempilha até a raiz (AuthGate).
  void _onAuthChanged() {
    if (_auth.status == AuthStatus.unauthenticated) {
      _savedBooks.clear();
      _navigatorKey.currentState?.popUntil((r) => r.isFirst);
    }
  }

  @override
  void dispose() {
    _links?.dispose();
    _auth.removeListener(_onAuthChanged);
    _auth.dispose();
    _savedBooks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _api),
        Provider<AuthApiService>.value(value: _authService),
        Provider<AdminApiService>.value(value: _adminService),
        Provider<CatalogApiService>.value(value: _catalogService),
        Provider<ProfileApiService>.value(value: _profileService),
        Provider<InvitesApiService>.value(value: _invitesService),
        ChangeNotifierProvider<AuthController>.value(value: _auth),
        ChangeNotifierProvider<SavedBooksController>.value(value: _savedBooks),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Colli Books',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9F9F22)),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
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