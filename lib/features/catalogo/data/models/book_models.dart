// features/catalogo/data/models/book_models.dart
import '../../../../core/network/media_url.dart';
import 'education_level_model.dart';
import 'theme_model.dart';

/// Item do catálogo e da Minha Seleção (GET /books, GET /me/saved-books).
class BookSummary {
  const BookSummary({
    required this.id,
    required this.title,
    required this.author,
    required this.themes,
    this.coverUrl,
    this.year,
    this.educationLevel,
    this.isSaved = false,
  });

  final int id;
  final String title;
  final String author;
  final String? coverUrl; // relativo; use coverUri para exibir
  final int? year;
  final EducationLevelModel? educationLevel; // uma escolaridade por obra, ou null
  final List<ThemeModel> themes;
  final bool isSaved;

  String? get coverUri => resolveMediaUrl(coverUrl);

  factory BookSummary.fromJson(Map<String, dynamic> json) => BookSummary(
    id: json['id'] as int,
    title: json['title'] as String,
    author: json['author'] as String,
    coverUrl: json['cover_url'] as String?,
    year: json['year'] as int?,
    educationLevel: json['education_level'] == null
        ? null
        : EducationLevelModel.fromJson(json['education_level'] as Map<String, dynamic>),
    themes: [
      for (final t in json['themes'] as List) ThemeModel.fromJson(t as Map<String, dynamic>),
    ],
    isSaved: (json['is_saved'] as bool?) ?? false,
  );
}

/// Detalhe completo (GET /books/{id}, e resposta de POST/PATCH /books).
class BookDetail extends BookSummary {
  const BookDetail({
    required super.id,
    required super.title,
    required super.author,
    required super.themes,
    super.coverUrl,
    super.year,
    super.educationLevel,
    super.isSaved,
    this.synopsis,
    this.isbn,
    this.pageCount,
    this.edition,
    this.storeUrl,
    this.bookUrl,
    this.pedagogicalMaterialUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? synopsis;
  final String? isbn;
  final int? pageCount;
  final String? edition;
  final String? storeUrl;
  final String? bookUrl;
  final String? pedagogicalMaterialUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    final s = BookSummary.fromJson(json);
    return BookDetail(
      id: s.id,
      title: s.title,
      author: s.author,
      themes: s.themes,
      coverUrl: s.coverUrl,
      year: s.year,
      educationLevel: s.educationLevel,
      isSaved: s.isSaved,
      synopsis: json['synopsis'] as String?,
      isbn: json['isbn'] as String?,
      pageCount: json['page_count'] as int?,
      edition: json['edition'] as String?,
      storeUrl: json['store_url'] as String?,
      bookUrl: json['book_url'] as String?,
      pedagogicalMaterialUrl: json['pedagogical_material_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}