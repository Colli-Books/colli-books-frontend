import 'package:colli_books_frontend/core/network/api_client.dart';
import 'package:colli_books_frontend/core/network/api_exception.dart';
import 'package:colli_books_frontend/features/admin/data/models/admin_overview_model.dart';
import 'package:colli_books_frontend/features/admin/data/models/teacher_model.dart';
import 'package:colli_books_frontend/features/admin/data/services/admin_api_service.dart';
import 'package:colli_books_frontend/features/catalogo/data/models/book_form.dart';
import 'package:colli_books_frontend/features/catalogo/data/models/book_models.dart';
import 'package:colli_books_frontend/features/catalogo/data/models/education_level_model.dart';
import 'package:colli_books_frontend/features/catalogo/data/models/theme_model.dart';
import 'package:colli_books_frontend/features/catalogo/data/services/catalog_api_service.dart';

import 'e2e_env.dart';

// ---------------------------------------------------------------------------
// Dados únicos por execução
//
// A API não tem DELETE: o que os testes criam FICA no banco. Por isso todo nome,
// e-mail e ISBN leva um sufixo único, e o ideal é um banco de TESTE recriado a cada execução.
// ---------------------------------------------------------------------------

final String _runId = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
int _seq = 0;

/// Texto único (ex.: "Tema A kx3f9a-4"). O sufixo é minúsculo e sem acentos.
String uniq(String label) => '$label $_runId-${_seq++}';

String uniqEmail(String label) => 'e2e-$label-$_runId-${_seq++}@example.com';

/// 13 dígitos únicos, só números (ex.: 9786512345678).
String uniqIsbn() {
  final tail = ((DateTime.now().microsecondsSinceEpoch + _seq++) % 100000000)
      .toString()
      .padLeft(8, '0');
  return '97865$tail';
}

/// Formato do IsbnInputFormatter do app: 978-65-6079-046-9 (ajuste se o seu for diferente).
String formatIsbn(String digits) =>
    '${digits.substring(0, 3)}-${digits.substring(3, 5)}-${digits.substring(5, 9)}'
        '-${digits.substring(9, 12)}-${digits.substring(12)}';

String digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

/// Remove acentos (para testar a busca "ignorando acentuação").
String foldAccents(String s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
  const to = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';
  var out = s;
  for (var i = 0; i < from.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  return out;
}

const kTeacherPassword = 'E2e-Senha-123';

class TestTeacher {
  const TestTeacher({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
    required this.usedInviteToken,
  });

  final int id;
  final String email;
  final String name;
  final String password;

  /// Token do convite que ESTE professor já usou (serve ao teste "convite já utilizado").
  final String usedInviteToken;
}

// ---------------------------------------------------------------------------
// Cliente da API para preparar dados
// ---------------------------------------------------------------------------

/// Fala com a API sem passar pelo app: login como admin num ApiClient PRÓPRIO,
/// que não toca o armazenamento seguro (a sessão do app sob teste fica intacta).
///
/// Prepara-se o estado pela API e testa-se só a interface: rápido e independente entre testes.
class E2eApi {
  E2eApi._(ApiClient api)
      : admin = AdminApiService(api),
        catalog = CatalogApiService(api);

  final AdminApiService admin;
  final CatalogApiService catalog;

  /// O access token vale ~15 min: crie uma instância por teste.
  static Future<E2eApi> asAdmin() async {
    E2eEnv.ensure();
    final api = await _loginClient(E2eEnv.adminEmail, E2eEnv.adminPassword);
    return E2eApi._(api);
  }

  static Future<ApiClient> _loginClient(String email, String password) async {
    final api = ApiClient();
    final json = await api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      authenticated: false,
    ) as Map<String, dynamic>;
    api.setAccessToken(json['access_token'] as String);
    return api;
  }

  /// Devolve o erro (ex.: INVITE_INVALID), ou null se o convite está válido.
  static Future<ApiException?> verifyInvite(String token) async {
    try {
      await ApiClient().post('/invites/verify', body: {'token': token}, authenticated: false);
      return null;
    } on ApiException catch (e) {
      return e;
    }
  }

  // --- Professores ---------------------------------------------------------

  /// Cria o professor E conclui o cadastro pela API: devolve uma conta ATIVA, pronta para login.
  Future<TestTeacher> createActiveTeacher({String label = 'prof', String? name}) async {
    final email = uniqEmail(label);
    final invite = await admin.createTeacher(email);
    final fullName = name ?? uniq('Professor');
    await ApiClient().post(
      '/invites/accept',
      body: {
        'token': invite.inviteCode,
        'full_name': fullName,
        'password': kTeacherPassword,
      },
      authenticated: false,
    );
    return TestTeacher(
      id: invite.id,
      email: email,
      name: fullName,
      password: kTeacherPassword,
      usedInviteToken: invite.inviteCode,
    );
  }

  Future<TeacherModel?> teacherByEmail(String email) async {
    final list = await admin.listTeachers(query: email);
    for (final t in list) {
      if (t.email.toLowerCase() == email.toLowerCase()) return t;
    }
    return null;
  }

  Future<AdminOverviewModel> overview() => admin.fetchOverview();

  /// Salva uma obra na Minha Seleção do professor (login próprio, sem tocar o app).
  Future<void> saveBookFor(TestTeacher teacher, int bookId) async {
    final api = await _loginClient(teacher.email, teacher.password);
    await CatalogApiService(api).saveBook(bookId);
  }

  // --- Catálogo ------------------------------------------------------------

  Future<ThemeModel> theme([String label = 'Tema']) =>
      catalog.createTheme(name: uniq(label));

  Future<EducationLevelModel> level([String label = 'Nivel']) =>
      catalog.createEducationLevel(name: uniq(label), sortOrder: 90);

  Future<BookDetail> book({
    String? title,
    String author = 'Autora E2E',
    String? isbn,
    String? synopsis,
    int? pageCount,
    int? year,
    int? levelId,
    List<int> themeIds = const [],
    String? storeUrl,
  }) {
    return catalog.createBook(BookForm(
      title: title ?? uniq('Livro'),
      author: author,
      isbn: isbn,
      synopsis: synopsis,
      pageCount: pageCount,
      year: year,
      educationLevelId: levelId,
      themeIds: themeIds,
      storeUrl: storeUrl,
    ));
  }
}

// ---------------------------------------------------------------------------
// Cenário de catálogo reutilizado pelos testes de busca/filtro
// ---------------------------------------------------------------------------

/// Dois temas, duas escolaridades e três obras:
///   b1 → tema A + escolaridade 1 (com todos os campos de detalhe)
///   b2 → temas A e B + escolaridade 2
///   b3 → sem tema e sem escolaridade
///
/// Todos os nomes são únicos nesta execução, então um filtro pelo tema "A" devolve
/// exatamente as obras criadas aqui (mesmo que o banco já tenha outras).
class CatalogFixture {
  CatalogFixture._({
    required this.themeA,
    required this.themeB,
    required this.level1,
    required this.level2,
    required this.b1,
    required this.b2,
    required this.b3,
  });

  final ThemeModel themeA;
  final ThemeModel themeB;
  final EducationLevelModel level1;
  final EducationLevelModel level2;
  final BookDetail b1;
  final BookDetail b2;
  final BookDetail b3;

  static Future<CatalogFixture> seed(E2eApi api) async {
    final themeA = await api.theme('Tema A');
    final themeB = await api.theme('Tema B');
    final level1 = await api.level('Nivel 1');
    final level2 = await api.level('Nivel 2');

    final b1 = await api.book(
      title: uniq('Árvore Mágica'),
      author: 'Autora E2E',
      isbn: uniqIsbn(),
      synopsis: uniq('Sinopse E2E'),
      pageCount: 40,
      levelId: level1.id,
      themeIds: [themeA.id],
      storeUrl: 'https://www.collibooksloja.com/livro-e2e',
    );
    final b2 = await api.book(
      title: uniq('Rio Encantado'),
      levelId: level2.id,
      themeIds: [themeA.id, themeB.id],
    );
    final b3 = await api.book(title: uniq('Livro Solto'));

    return CatalogFixture._(
      themeA: themeA,
      themeB: themeB,
      level1: level1,
      level2: level2,
      b1: b1,
      b2: b2,
      b3: b3,
    );
  }
}