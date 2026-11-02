import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_helpers.dart';
import '../models/book_form.dart';
import '../models/book_models.dart';
import '../models/education_level_model.dart';
import '../models/theme_model.dart';

enum BookSort { relevance, title, year } // .name == valor aceito pela API

class CatalogApiService {
  CatalogApiService(this._api);

  final ApiClient _api;

  // --- Obras ---------------------------------------------------------------

  /// GET /books: lista completa (sem paginação). Cada item já traz `is_saved`.
  Future<List<BookSummary>> listBooks({
    String? query,
    int? themeId,
    int? educationLevelId,
    BookSort sort = BookSort.relevance,
  }) async {
    final q = query?.trim() ?? '';
    final raw = await _api.get('/books', queryParameters: {
      'q': q.isEmpty ? null : q,
      'theme_id': themeId,
      'education_level_id': educationLevelId,
      'sort': sort.name,
    });
    return parseResponse(() => [
      for (final e in asJsonList(raw)) BookSummary.fromJson(e as Map<String, dynamic>),
    ]);
  }

  /// GET /books/{id}. Erro: NOT_FOUND.
  Future<BookDetail> getBook(int id) async {
    final json = asJsonMap(await _api.get('/books/$id'));
    return parseResponse(() => BookDetail.fromJson(json));
  }

  /// POST /books (multipart). Erros: ISBN_ALREADY_REGISTERED (409),
  /// IMAGE_INVALID / IMAGE_TOO_LARGE / VALIDATION_ERROR (422, campo a campo em details).
  Future<BookDetail> createBook(BookForm f) async {
    final json = asJsonMap(await _api.sendMultipart(
      'POST',
      '/books',
      fields: {
        'title': f.title.trim(),
        'author': f.author.trim(),
        ..._optionalFields(f, sendEmpty: false),
      },
      repeated: f.themeIds.isEmpty ? const {} : {'theme_ids': [for (final id in f.themeIds) '$id']},
      coverBytes: f.coverBytes,
      coverFilename: f.coverFilename,
    ));
    return parseResponse(() => BookDetail.fromJson(json));
  }

  /// PATCH /books/{id} (multipart). Envia o formulário inteiro:
  /// vazio = limpar, `theme_ids=` vazio = remover todos os temas,
  /// capa só se houver arquivo novo.
  Future<BookDetail> updateBook(int id, BookForm f) async {
    final json = asJsonMap(await _api.sendMultipart(
      'PATCH',
      '/books/$id',
      fields: {
        'title': f.title.trim(),
        'author': f.author.trim(),
        ..._optionalFields(f, sendEmpty: true),
        if (f.themeIds.isEmpty) 'theme_ids': '',
      },
      repeated: f.themeIds.isEmpty ? const {} : {'theme_ids': [for (final i in f.themeIds) '$i']},
      coverBytes: f.coverBytes,
      coverFilename: f.coverFilename,
    ));
    return parseResponse(() => BookDetail.fromJson(json));
  }

  Map<String, String> _optionalFields(BookForm f, {required bool sendEmpty}) {
    final raw = <String, String?>{
      'synopsis': f.synopsis,
      'isbn': f.isbn,
      'page_count': f.pageCount?.toString(),
      'edition': f.edition,
      'year': f.year?.toString(),
      'store_url': f.storeUrl,
      'book_url': f.bookUrl,
      'pedagogical_material_url': f.pedagogicalMaterialUrl,
      'education_level_id': f.educationLevelId?.toString(),
    };
    final out = <String, String>{};
    raw.forEach((key, value) {
      final v = value?.trim() ?? '';
      if (v.isNotEmpty || sendEmpty) out[key] = v;
    });
    return out;
  }

  // --- Temas ---------------------------------------------------------------

  Future<List<ThemeModel>> listThemes() async {
    final raw = await _api.get('/themes');
    return parseResponse(() => [
      for (final e in asJsonList(raw)) ThemeModel.fromJson(e as Map<String, dynamic>),
    ]);
  }

  /// Erros: THEME_ALREADY_EXISTS (409), VALIDATION_ERROR.
  Future<ThemeModel> createTheme({required String name, String? description}) async {
    final d = description?.trim() ?? '';
    final json = asJsonMap(await _api.post('/themes', body: {
      'name': name.trim(),
      if (d.isNotEmpty) 'description': d,
    }));
    return parseResponse(() => ThemeModel.fromJson(json));
  }

  /// PATCH parcial. Ausente ou vazio = não altera (a API não permite limpar a descrição).
  Future<ThemeModel> updateTheme(int id, {String? name, String? description}) async {
    final json = asJsonMap(await _api.patch('/themes/$id', body: {
      if (name != null) 'name': name.trim(),
      if (description != null) 'description': description.trim(),
    }));
    return parseResponse(() => ThemeModel.fromJson(json));
  }

  // --- Escolaridades -------------------------------------------------------

  Future<List<EducationLevelModel>> listEducationLevels() async {
    final raw = await _api.get('/education-levels');
    return parseResponse(() => [
      for (final e in asJsonList(raw)) EducationLevelModel.fromJson(e as Map<String, dynamic>),
    ]);
  }

  /// Erros: EDUCATION_LEVEL_ALREADY_EXISTS (409), VALIDATION_ERROR.
  Future<EducationLevelModel> createEducationLevel({
    required String name,
    int sortOrder = 0,
  }) async {
    final json = asJsonMap(await _api.post('/education-levels', body: {
      'name': name.trim(),
      'sort_order': sortOrder,
    }));
    return parseResponse(() => EducationLevelModel.fromJson(json));
  }

  Future<EducationLevelModel> updateEducationLevel(int id, {String? name, int? sortOrder}) async {
    final json = asJsonMap(await _api.patch('/education-levels/$id', body: {
      if (name != null) 'name': name.trim(),
      if (sortOrder != null) 'sort_order': sortOrder,
    }));
    return parseResponse(() => EducationLevelModel.fromJson(json));
  }

  // --- Minha Seleção (usado na parte do professor) ---------------------------

  Future<List<BookSummary>> listSavedBooks() async {
    final raw = await _api.get('/me/saved-books');
    return parseResponse(() => [
      for (final e in asJsonList(raw)) BookSummary.fromJson(e as Map<String, dynamic>),
    ]);
  }

  /// Idempotente (204). Erro: NOT_FOUND se a obra não existe.
  Future<void> saveBook(int bookId) => _api.put('/me/saved-books/$bookId');

  Future<void> unsaveBook(int bookId) => _api.delete('/me/saved-books/$bookId');
}