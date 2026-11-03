// features/catalogo/data/models/book_form.dart

import 'dart:typed_data';

/// Estado do formulário de cadastro/edição de obra.
class BookForm {
  const BookForm({
    required this.title,
    required this.author,
    this.synopsis,
    this.isbn,
    this.pageCount,
    this.edition,
    this.year,
    this.storeUrl,
    this.bookUrl,
    this.pedagogicalMaterialUrl,
    this.educationLevelId,
    this.themeIds = const [],
    this.coverBytes,
    this.coverFilename,
  });

  final String title;
  final String author;
  final String? synopsis;
  final String? isbn;
  final int? pageCount;
  final String? edition;
  final int? year;
  final String? storeUrl;
  final String? bookUrl;
  final String? pedagogicalMaterialUrl;
  final int? educationLevelId;
  final List<int> themeIds;

  final Uint8List? coverBytes;
  final String? coverFilename;
}