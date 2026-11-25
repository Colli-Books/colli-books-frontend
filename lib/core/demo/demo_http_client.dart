import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Cliente HTTP em memória para o Modo Demonstração (QR Code / Banner).
/// Simula toda a API REST (`/api/v1/*`) localmente, sem backend e sem banco de
/// dados, com obras, temas, escolaridades e professores 100% genéricos/fictícios.
class DemoHttpClient extends http.BaseClient {
  DemoHttpClient() {
    _resetSeedData();
  }

  static const String demoInviteToken = 'CONVITEDEMO';

  // --- Estado em memória da sessão atual -----------------------------------

  final List<Map<String, dynamic>> _themes = [];
  final List<Map<String, dynamic>> _educationLevels = [];
  final List<Map<String, dynamic>> _books = [];
  final List<Map<String, dynamic>> _teachers = [];
  final Set<int> _savedBookIds = {1, 3};

  Map<String, dynamic> _currentUser = _teacherUser;
  List<int> _teacherThemeIds = [1, 2, 4];
  List<int> _teacherLevelIds = [1, 2];

  int _nextBookId = 100;
  int _nextThemeId = 100;
  int _nextLevelId = 100;
  int _nextTeacherId = 100;

  static final Map<String, dynamic> _teacherUser = {
    'id': 2,
    'email': 'professor@exemplo.com',
    'full_name': 'Prof. Alex Exemplo (Demonstração)',
    'school': 'Escola Modelo de Demonstração',
    'role': 'teacher',
    'status': 'active',
  };

  static final Map<String, dynamic> _adminUser = {
    'id': 1,
    'email': 'admin@exemplo.com',
    'full_name': 'Equipe Editorial (Demonstração)',
    'school': null,
    'role': 'admin',
    'status': 'active',
  };

  void _resetSeedData() {
    _educationLevels
      ..clear()
      ..addAll([
        {'id': 1, 'name': 'Educação Infantil', 'sort_order': 1},
        {'id': 2, 'name': 'Ensino Fundamental I', 'sort_order': 2},
        {'id': 3, 'name': 'Ensino Fundamental II', 'sort_order': 3},
        {'id': 4, 'name': 'Ensino Médio', 'sort_order': 4},
      ]);

    _themes
      ..clear()
      ..addAll([
        {
          'id': 1,
          'name': 'Leitura e Criatividade',
          'description': 'Obras fictícias para estimular o hábito de leitura e imaginação.',
        },
        {
          'id': 2,
          'name': 'Cidadania e Convivência',
          'description': 'Temas transversais sobre respeito, empatia e trabalho em equipe.',
        },
        {
          'id': 3,
          'name': 'Ciências e Natureza',
          'description': 'Exploração científica, curiosidades naturais e sustentabilidade.',
        },
        {
          'id': 4,
          'name': 'Raciocínio e Lógica',
          'description': 'Desafios lógicos, resolução de problemas e pensamento crítico.',
        },
        {
          'id': 5,
          'name': 'Arte e Cultura',
          'description': 'Expressão artística, diversidade cultural e música.',
        },
        {
          'id': 6,
          'name': 'Tecnologia e Futuro',
          'description': 'Inovação, cultura digital e transformações na sociedade.',
        },
      ]);

    final nowIso = DateTime.now().toUtc().toIso8601String();

    _books
      ..clear()
      ..addAll([
        {
          'id': 1,
          'title': 'Livro Exemplo 01: A Jornada do Conhecimento',
          'author': 'Autor Fictício A',
          'synopsis':
              'Esta é uma obra demonstrativa genérica criada exclusivamente para simular '
              'a visualização de detalhes no aplicativo. Apresenta como a sinopse, os temas '
              'transversais, a faixa de escolaridade e os materiais de apoio pedagógico '
              'são exibidos para os professores.',
          'isbn': '978-00-00000-01-1',
          'page_count': 64,
          'edition': '1ª Edição Demo',
          'year': 2026,
          'cover_url':
              'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80',
          'store_url': 'https://www.collibooks.com/',
          'book_url': 'https://www.collibooks.com/',
          'pedagogical_material_url': 'https://www.collibooks.com/',
          'education_level_ids': [1, 2],
          'theme_ids': [1, 2],
          'created_at': nowIso,
          'updated_at': nowIso,
        },
        {
          'id': 2,
          'title': 'Livro Exemplo 02: Explorando a Natureza',
          'author': 'Autora Fictícia B',
          'synopsis':
              'Obra ilustrativa de demonstração voltada ao ensino de ciências e meio ambiente. '
              'Permite testar a busca textual, os filtros combinados por escolaridade e tema, '
              'além da adição e remoção da lista Minha Seleção.',
          'isbn': '978-00-00000-02-8',
          'page_count': 80,
          'edition': '2ª Edição Demo',
          'year': 2025,
          'cover_url':
              'https://images.unsplash.com/photo-1532012164546-f432f2e3777f?w=400&q=80',
          'store_url': 'https://www.collibooks.com/',
          'book_url': 'https://www.collibooks.com/',
          'pedagogical_material_url': 'https://www.collibooks.com/',
          'education_level_ids': [2],
          'theme_ids': [3, 2],
          'created_at': nowIso,
          'updated_at': nowIso,
        },
        {
          'id': 3,
          'title': 'Livro Exemplo 03: Desafios da Lógica',
          'author': 'Autor Fictício C',
          'synopsis':
              'Título fictício para demonstração do catálogo. Simula um livro paradidático '
              'com atividades interdisciplinares para o desenvolvimento do pensamento lógico '
              'e resolução colaborativa de problemas em sala de aula.',
          'isbn': '978-00-00000-03-5',
          'page_count': 96,
          'edition': '1ª Edição Demo',
          'year': 2026,
          'cover_url':
              'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80',
          'store_url': 'https://www.collibooks.com/',
          'book_url': 'https://www.collibooks.com/',
          'pedagogical_material_url': 'https://www.collibooks.com/',
          'education_level_ids': [2, 3],
          'theme_ids': [4, 6],
          'created_at': nowIso,
          'updated_at': nowIso,
        },
        {
          'id': 4,
          'title': 'Livro Exemplo 04: Cores, Sons e Movimento',
          'author': 'Autora Fictícia D',
          'synopsis':
              'Livro genérico de teste para a faixa de Educação Infantil. Demonstra como '
              'o professor pode consultar rapidamente indicações de faixa etária, número '
              'de páginas e temas pedagógicos abordados.',
          'isbn': '978-00-00000-04-2',
          'page_count': 42,
          'edition': '1ª Edição Demo',
          'year': 2024,
          'cover_url':
              'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80',
          'store_url': 'https://www.collibooks.com/',
          'book_url': 'https://www.collibooks.com/',
          'pedagogical_material_url': 'https://www.collibooks.com/',
          'education_level_ids': [1],
          'theme_ids': [1, 5],
          'created_at': nowIso,
          'updated_at': nowIso,
        },
        {
          'id': 5,
          'title': 'Livro Exemplo 05: Sociedade e Cidadania Digital',
          'author': 'Autor Fictício E',
          'synopsis':
              'Volume demonstrativo para os anos finais e Ensino Médio. Simula uma obra '
              'voltada a debates em sala de aula sobre ética, convivência, tecnologia '
              'e projetos interdisciplinares.',
          'isbn': '978-00-00000-05-9',
          'page_count': 128,
          'edition': '3ª Edição Demo',
          'year': 2025,
          'cover_url':
              'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80',
          'store_url': 'https://www.collibooks.com/',
          'book_url': 'https://www.collibooks.com/',
          'pedagogical_material_url': 'https://www.collibooks.com/',
          'education_level_ids': [3, 4],
          'theme_ids': [2, 6],
          'created_at': nowIso,
          'updated_at': nowIso,
        },
        {
          'id': 6,
          'title': 'Livro Exemplo 06: Contos e Crônicas de Sala de Aula',
          'author': 'Autora Fictícia F',
          'synopsis':
              'Coletânea fictícia para avaliação de interface e experiência do usuário. '
              'Todos os dados desta versão são simulados em memória e não utilizam '
              'banco de dados real.',
          'isbn': '978-00-00000-06-6',
          'page_count': 110,
          'edition': '1ª Edição Demo',
          'year': 2023,
          'cover_url':
              'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400&q=80',
          'store_url': 'https://www.collibooks.com/',
          'book_url': 'https://www.collibooks.com/',
          'pedagogical_material_url': 'https://www.collibooks.com/',
          'education_level_ids': [3, 4],
          'theme_ids': [1, 5],
          'created_at': nowIso,
          'updated_at': nowIso,
        },
      ]);

    _teachers
      ..clear()
      ..addAll([
        {
          'id': 2,
          'email': 'professor@exemplo.com',
          'full_name': 'Prof. Alex Exemplo',
          'school': 'Escola Modelo A',
          'status': 'active',
        },
        {
          'id': 3,
          'email': 'docente.demo@exemplo.com',
          'full_name': 'Profa. Beatriz Fictícia',
          'school': 'Colégio Demonstrativo B',
          'status': 'active',
        },
        {
          'id': 4,
          'email': 'convidado.pendente@exemplo.com',
          'full_name': null,
          'school': null,
          'status': 'invite_pending',
        },
      ]);
  }

  // --- Interceptador HTTP ---------------------------------------------------

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Pequeno atraso apenas para feedback visual natural nos botões
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final bodyBytes = await request.finalize().toBytes();
    Map<String, dynamic> jsonBody = const {};
    if (bodyBytes.isNotEmpty) {
      try {
        final decoded = jsonDecode(utf8.decode(bodyBytes));
        if (decoded is Map<String, dynamic>) jsonBody = decoded;
      } catch (_) {
        // Ignora se for multipart (tratado separadamente)
      }
    }

    final method = request.method.toUpperCase();
    final uri = request.url;
    final path = uri.path.replaceFirst(RegExp(r'^/api/v1'), '');

    final result = _route(
      method: method,
      path: path,
      uri: uri,
      request: request,
      bodyBytes: bodyBytes,
      jsonBody: jsonBody,
    );

    final statusCode = result.$1;
    final payload = result.$2;

    if (statusCode == 204 || payload == null) {
      return http.StreamedResponse(const Stream.empty(), statusCode);
    }

    final encoded = utf8.encode(jsonEncode(payload));
    return http.StreamedResponse(
      Stream.value(encoded),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  (int, dynamic) _route({
    required String method,
    required String path,
    required Uri uri,
    required http.BaseRequest request,
    required Uint8List bodyBytes,
    required Map<String, dynamic> jsonBody,
  }) {
    // --- AUTH ---------------------------------------------------------------
    if (method == 'POST' && path == '/auth/login') {
      final email = (jsonBody['email'] as String? ?? '').trim().toLowerCase();
      if (email.contains('admin') || email.contains('editora')) {
        _currentUser = Map<String, dynamic>.from(_adminUser)..['email'] = email;
      } else {
        _currentUser = Map<String, dynamic>.from(_teacherUser)
          ..['email'] = email.isEmpty ? 'professor@exemplo.com' : email;
      }
      return (
        200,
        {
          'access_token': 'demo-access-token-${_currentUser['role']}',
          'refresh_token': 'demo-refresh-token-${_currentUser['role']}',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': _currentUser,
        },
      );
    }

    if (method == 'POST' && path == '/auth/refresh') {
      final rt = jsonBody['refresh_token'] as String? ?? '';
      if (rt.endsWith('admin')) {
        _currentUser = Map<String, dynamic>.from(_adminUser);
      } else {
        _currentUser = Map<String, dynamic>.from(_teacherUser);
      }
      return (
        200,
        {
          'access_token': 'demo-access-token-${_currentUser['role']}',
          'refresh_token': 'demo-refresh-token-${_currentUser['role']}',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': _currentUser,
        },
      );
    }

    if (method == 'GET' && path == '/auth/me') {
      return (200, _currentUser);
    }

    if (method == 'POST' && path == '/auth/logout') {
      return (204, null);
    }

    if (method == 'POST' && path == '/auth/forgot-password') {
      return (
        202,
        {
          'message':
              'Modo Demonstração: use qualquer código (ex: DEMO123) abaixo para simular a redefinição de senha.',
        },
      );
    }

    if (method == 'POST' && path == '/auth/reset-password') {
      return (200, {'message': 'Senha redefinida com sucesso (Modo Demonstração).'});
    }

    // --- INVITES ------------------------------------------------------------
    if (method == 'POST' && path == '/invites/verify') {
      return (200, {'email': 'novo.professor@exemplo.com'});
    }

    if (method == 'POST' && path == '/invites/accept') {
      final fullName = (jsonBody['full_name'] as String? ?? 'Prof. Convidado').trim();
      final school = (jsonBody['school'] as String?)?.trim();
      _currentUser = {
        'id': 99,
        'email': 'novo.professor@exemplo.com',
        'full_name': fullName.isEmpty ? 'Prof. Convidado (Demo)' : fullName,
        'school': (school?.isEmpty ?? true) ? 'Escola Exemplo' : school,
        'role': 'teacher',
        'status': 'active',
      };
      return (
        200,
        {
          'access_token': 'demo-access-token-teacher',
          'refresh_token': 'demo-refresh-token-teacher',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': _currentUser,
        },
      );
    }

    if (method == 'POST' && path == '/invites/resend') {
      return (202, {'message': 'Convite reenviado (Modo Demonstração).'});
    }

    // --- PROFILE (/me) ------------------------------------------------------
    if (method == 'PATCH' && path == '/me') {
      if (jsonBody.containsKey('full_name')) {
        _currentUser['full_name'] = jsonBody['full_name'];
      }
      if (jsonBody.containsKey('school')) {
        final s = (jsonBody['school'] as String?)?.trim() ?? '';
        _currentUser['school'] = s.isEmpty ? null : s;
      }
      return (200, _currentUser);
    }

    if (method == 'PUT' && path == '/me/password') {
      return (204, null);
    }

    if (method == 'PUT' && path == '/me/interests') {
      _teacherThemeIds = [
        for (final id in (jsonBody['theme_ids'] as List? ?? const []))
          if (id is int) id,
      ];
      _teacherLevelIds = [
        for (final id in (jsonBody['education_level_ids'] as List? ?? const []))
          if (id is int) id,
      ];
      return (
        200,
        {
          'themes': [
            for (final t in _themes)
              if (_teacherThemeIds.contains(t['id'])) t,
          ],
          'education_levels': [
            for (final l in _educationLevels)
              if (_teacherLevelIds.contains(l['id'])) l,
          ],
        },
      );
    }

    // --- SAVED BOOKS (/me/saved-books) --------------------------------------
    if (method == 'GET' && path == '/me/saved-books') {
      final saved = [
        for (final b in _books)
          if (_savedBookIds.contains(b['id'])) _serializeBookSummary(b),
      ];
      return (200, saved);
    }

    final savedMatch = RegExp(r'^/me/saved-books/(\d+)$').firstMatch(path);
    if (savedMatch != null) {
      final bookId = int.parse(savedMatch.group(1)!);
      if (method == 'PUT') {
        _savedBookIds.add(bookId);
        return (204, null);
      }
      if (method == 'DELETE') {
        _savedBookIds.remove(bookId);
        return (204, null);
      }
    }

    // --- BOOKS (/books) -----------------------------------------------------
    if (method == 'GET' && path == '/books') {
      final q = (uri.queryParameters['q'] ?? '').trim().toLowerCase();
      final themeIds = _parseQueryInts(uri.queryParametersAll['theme_ids']);
      final levelIds = _parseQueryInts(uri.queryParametersAll['education_level_ids']);
      final sort = uri.queryParameters['sort'] ?? 'relevance';

      final filtered = _books.where((b) {
        if (q.isNotEmpty) {
          final title = (b['title'] as String).toLowerCase();
          final author = (b['author'] as String).toLowerCase();
          final synopsis = (b['synopsis'] as String? ?? '').toLowerCase();
          if (!title.contains(q) && !author.contains(q) && !synopsis.contains(q)) {
            return false;
          }
        }
        if (themeIds.isNotEmpty) {
          final bThemes = (b['theme_ids'] as List).cast<int>();
          if (!bThemes.any(themeIds.contains)) return false;
        }
        if (levelIds.isNotEmpty) {
          final bLevels = (b['education_level_ids'] as List).cast<int>();
          if (!bLevels.any(levelIds.contains)) return false;
        }
        return true;
      }).toList();

      if (sort == 'title') {
        filtered.sort((a, b) => (a['title'] as String).compareTo(b['title'] as String));
      } else if (sort == 'year') {
        filtered.sort((a, b) => ((b['year'] as int?) ?? 0).compareTo((a['year'] as int?) ?? 0));
      }

      return (200, [for (final b in filtered) _serializeBookSummary(b)]);
    }

    if (method == 'POST' && path == '/books') {
      final parsed = _parseMultipartBook(request, bodyBytes);
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final newBook = <String, dynamic>{
        'id': _nextBookId++,
        'title': parsed['title'] ?? 'Nova Obra Exemplo',
        'author': parsed['author'] ?? 'Autor Exemplo',
        'synopsis': parsed['synopsis'] ?? 'Sinopse demonstrativa criada durante o teste.',
        'isbn': parsed['isbn'] ?? '978-00-00000-99-9',
        'page_count': int.tryParse(parsed['page_count']?.toString() ?? '') ?? 64,
        'edition': parsed['edition'] ?? '1ª Edição Demo',
        'year': int.tryParse(parsed['year']?.toString() ?? '') ?? 2026,
        'cover_url':
            'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80',
        'store_url': parsed['store_url'] ?? 'https://www.collibooks.com/',
        'book_url': parsed['book_url'] ?? 'https://www.collibooks.com/',
        'pedagogical_material_url':
            parsed['pedagogical_material_url'] ?? 'https://www.collibooks.com/',
        'education_level_ids': parsed['education_level_ids'] as List<int>? ?? [1],
        'theme_ids': parsed['theme_ids'] as List<int>? ?? [1],
        'created_at': nowIso,
        'updated_at': nowIso,
      };
      _books.insert(0, newBook);
      return (201, _serializeBookDetail(newBook));
    }

    final bookMatch = RegExp(r'^/books/(\d+)$').firstMatch(path);
    if (bookMatch != null) {
      final id = int.parse(bookMatch.group(1)!);
      final idx = _books.indexWhere((b) => b['id'] == id);
      if (idx == -1) {
        return (404, {'code': 'NOT_FOUND', 'message': 'Obra não encontrada.'});
      }

      if (method == 'GET') {
        return (200, _serializeBookDetail(_books[idx]));
      }

      if (method == 'PATCH') {
        final parsed = _parseMultipartBook(request, bodyBytes);
        final book = _books[idx];
        if (parsed['title'] != null && (parsed['title'] as String).isNotEmpty) {
          book['title'] = parsed['title'];
        }
        if (parsed['author'] != null && (parsed['author'] as String).isNotEmpty) {
          book['author'] = parsed['author'];
        }
        if (parsed.containsKey('synopsis')) book['synopsis'] = parsed['synopsis'];
        if (parsed.containsKey('isbn')) book['isbn'] = parsed['isbn'];
        if (parsed.containsKey('edition')) book['edition'] = parsed['edition'];
        if (parsed.containsKey('page_count')) {
          book['page_count'] = int.tryParse(parsed['page_count']?.toString() ?? '');
        }
        if (parsed.containsKey('year')) {
          book['year'] = int.tryParse(parsed['year']?.toString() ?? '');
        }
        if (parsed.containsKey('store_url')) book['store_url'] = parsed['store_url'];
        if (parsed.containsKey('book_url')) book['book_url'] = parsed['book_url'];
        if (parsed.containsKey('pedagogical_material_url')) {
          book['pedagogical_material_url'] = parsed['pedagogical_material_url'];
        }
        if (parsed['theme_ids'] is List<int>) {
          book['theme_ids'] = parsed['theme_ids'];
        }
        if (parsed['education_level_ids'] is List<int>) {
          book['education_level_ids'] = parsed['education_level_ids'];
        }
        book['updated_at'] = DateTime.now().toUtc().toIso8601String();
        return (200, _serializeBookDetail(book));
      }

      if (method == 'DELETE') {
        _books.removeAt(idx);
        _savedBookIds.remove(id);
        return (204, null);
      }
    }

    // --- THEMES (/themes) ---------------------------------------------------
    if (method == 'GET' && path == '/themes') {
      return (200, _themes);
    }

    if (method == 'POST' && path == '/themes') {
      final newTheme = {
        'id': _nextThemeId++,
        'name': (jsonBody['name'] as String? ?? 'Novo Tema Exemplo').trim(),
        'description': (jsonBody['description'] as String?)?.trim(),
      };
      _themes.add(newTheme);
      return (201, newTheme);
    }

    final themeMatch = RegExp(r'^/themes/(\d+)$').firstMatch(path);
    if (themeMatch != null) {
      final id = int.parse(themeMatch.group(1)!);
      final idx = _themes.indexWhere((t) => t['id'] == id);
      if (idx == -1) return (404, {'code': 'NOT_FOUND', 'message': 'Tema não encontrado.'});

      if (method == 'PATCH') {
        if (jsonBody['name'] != null) _themes[idx]['name'] = jsonBody['name'];
        if (jsonBody['description'] != null) {
          _themes[idx]['description'] = jsonBody['description'];
        }
        return (200, _themes[idx]);
      }

      if (method == 'DELETE') {
        _themes.removeAt(idx);
        for (final b in _books) {
          (b['theme_ids'] as List).remove(id);
        }
        return (204, null);
      }
    }

    // --- EDUCATION LEVELS (/education-levels) -------------------------------
    if (method == 'GET' && path == '/education-levels') {
      final sorted = List<Map<String, dynamic>>.from(_educationLevels)
        ..sort((a, b) => ((a['sort_order'] as int?) ?? 0).compareTo((b['sort_order'] as int?) ?? 0));
      return (200, sorted);
    }

    if (method == 'POST' && path == '/education-levels') {
      final newLevel = {
        'id': _nextLevelId++,
        'name': (jsonBody['name'] as String? ?? 'Nova Escolaridade').trim(),
        'sort_order': (jsonBody['sort_order'] as int?) ?? (_educationLevels.length + 1),
      };
      _educationLevels.add(newLevel);
      return (201, newLevel);
    }

    final levelMatch = RegExp(r'^/education-levels/(\d+)$').firstMatch(path);
    if (levelMatch != null) {
      final id = int.parse(levelMatch.group(1)!);
      final idx = _educationLevels.indexWhere((l) => l['id'] == id);
      if (idx == -1) {
        return (404, {'code': 'NOT_FOUND', 'message': 'Escolaridade não encontrada.'});
      }

      if (method == 'PATCH') {
        if (jsonBody['name'] != null) _educationLevels[idx]['name'] = jsonBody['name'];
        if (jsonBody['sort_order'] != null) {
          _educationLevels[idx]['sort_order'] = jsonBody['sort_order'];
        }
        return (200, _educationLevels[idx]);
      }

      if (method == 'DELETE') {
        _educationLevels.removeAt(idx);
        for (final b in _books) {
          (b['education_level_ids'] as List).remove(id);
        }
        return (204, null);
      }
    }

    // --- ADMIN (/admin/*) ---------------------------------------------------
    if (method == 'GET' && path == '/admin/overview') {
      final pending = _teachers.where((t) => t['status'] == 'invite_pending').length;
      return (
        200,
        {
          'books_count': _books.length,
          'teachers_count': _teachers.length,
          'pending_invites_count': pending,
        },
      );
    }

    if (method == 'GET' && path == '/admin/teachers') {
      final q = (uri.queryParameters['q'] ?? '').trim().toLowerCase();
      final list = _teachers.where((t) {
        if (q.isEmpty) return true;
        final email = (t['email'] as String).toLowerCase();
        final name = (t['full_name'] as String? ?? '').toLowerCase();
        return email.contains(q) || name.contains(q);
      }).toList();
      return (200, list);
    }

    if (method == 'POST' && path == '/admin/teachers') {
      final email = (jsonBody['email'] as String? ?? 'novo.docente@exemplo.com').trim();
      final id = _nextTeacherId++;
      final teacher = {
        'id': id,
        'email': email,
        'full_name': null,
        'school': null,
        'status': 'invite_pending',
      };
      _teachers.insert(0, teacher);
      final expires = DateTime.now().toUtc().add(const Duration(days: 3)).toIso8601String();
      return (
        201,
        {
          'id': id,
          'email': email,
          'status': 'invite_pending',
          'invite_code': demoInviteToken,
          'invite_link': 'collibooks://convite?token=$demoInviteToken',
          'invite_expires_at': expires,
        },
      );
    }

    final resendMatch = RegExp(r'^/admin/teachers/(\d+)/invite$').firstMatch(path);
    if (method == 'POST' && resendMatch != null) {
      final id = int.parse(resendMatch.group(1)!);
      final teacher = _teachers.firstWhere(
        (t) => t['id'] == id,
        orElse: () => {'id': id, 'email': 'convidado@exemplo.com', 'status': 'invite_pending'},
      );
      final expires = DateTime.now().toUtc().add(const Duration(days: 3)).toIso8601String();
      return (
        200,
        {
          'id': id,
          'email': teacher['email'],
          'status': 'invite_pending',
          'invite_code': demoInviteToken,
          'invite_link': 'collibooks://convite?token=$demoInviteToken',
          'invite_expires_at': expires,
        },
      );
    }

    final deleteTeacherMatch = RegExp(r'^/admin/teachers/(\d+)$').firstMatch(path);
    if (method == 'DELETE' && deleteTeacherMatch != null) {
      final id = int.parse(deleteTeacherMatch.group(1)!);
      _teachers.removeWhere((t) => t['id'] == id);
      return (204, null);
    }

    return (200, {'status': 'ok'});
  }

  // --- Helpers de serialização ----------------------------------------------

  Set<int> _parseQueryInts(List<String>? raw) {
    if (raw == null || raw.isEmpty) return const {};
    final out = <int>{};
    for (final item in raw) {
      for (final part in item.split(',')) {
        final v = int.tryParse(part.trim());
        if (v != null) out.add(v);
      }
    }
    return out;
  }

  Map<String, dynamic> _serializeBookSummary(Map<String, dynamic> b) {
    final levelIds = (b['education_level_ids'] as List).cast<int>();
    final themeIds = (b['theme_ids'] as List).cast<int>();
    return {
      'id': b['id'],
      'title': b['title'],
      'author': b['author'],
      'cover_url': b['cover_url'],
      'year': b['year'],
      'education_levels': [
        for (final l in _educationLevels)
          if (levelIds.contains(l['id'])) l,
      ],
      'themes': [
        for (final t in _themes)
          if (themeIds.contains(t['id'])) {'id': t['id'], 'name': t['name']},
      ],
      'is_saved': _savedBookIds.contains(b['id']),
    };
  }

  Map<String, dynamic> _serializeBookDetail(Map<String, dynamic> b) {
    return {
      ..._serializeBookSummary(b),
      'synopsis': b['synopsis'],
      'isbn': b['isbn'],
      'page_count': b['page_count'],
      'edition': b['edition'],
      'store_url': b['store_url'],
      'book_url': b['book_url'],
      'pedagogical_material_url': b['pedagogical_material_url'],
      'created_at': b['created_at'],
      'updated_at': b['updated_at'],
    };
  }

  /// Extrai campos de texto básicos de uma requisição multipart/form-data.
  Map<String, dynamic> _parseMultipartBook(http.BaseRequest request, Uint8List bodyBytes) {
    final content = utf8.decode(bodyBytes, allowMalformed: true);
    final out = <String, dynamic>{};
    final themeIds = <int>[];
    final levelIds = <int>[];

    final partPattern = RegExp(
      r'Content-Disposition:\s*form-data;\s*name="([^"]+)"(?:\r?\n){2}([\s\S]*?)\r?\n--',
      multiLine: true,
    );

    for (final match in partPattern.allMatches(content)) {
      final name = match.group(1)?.trim() ?? '';
      final value = match.group(2)?.trim() ?? '';
      if (name == 'theme_ids') {
        final id = int.tryParse(value);
        if (id != null) themeIds.add(id);
      } else if (name == 'education_level_ids') {
        final id = int.tryParse(value);
        if (id != null) levelIds.add(id);
      } else if (name != 'cover') {
        out[name] = value;
      }
    }

    if (themeIds.isNotEmpty || out.containsKey('theme_ids')) {
      out['theme_ids'] = themeIds;
    }
    if (levelIds.isNotEmpty || out.containsKey('education_level_ids')) {
      out['education_level_ids'] = levelIds;
    }
    return out;
  }
}

