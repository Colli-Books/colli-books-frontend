// features/catalogo/presentation/controllers/books_controller.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/book_models.dart';
import '../../data/services/catalog_api_service.dart';

/// Catálogo com busca + filtros. Serve ao catálogo do admin e do professor.
class BooksController extends ChangeNotifier {
  BooksController(this._service, {this.onLoaded});

  final CatalogApiService _service;
  final void Function(List<BookSummary> books)? onLoaded;

  List<BookSummary> _items = const [];
  bool _loading = false;
  ApiException? _error;
  String _query = '';
  int? _themeId;
  int? _levelId;
  BookSort _sort = BookSort.relevance;
  Timer? _debounce;
  int _requestId = 0;
  bool _disposed = false;

  List<BookSummary> get items => _items;
  bool get isLoading => _loading;
  ApiException? get error => _error;
  int? get themeId => _themeId;
  int? get levelId => _levelId;
  BookSort get sort => _sort;
  bool get hasFilters => _query.isNotEmpty || _themeId != null || _levelId != null;

  /// Lista vazia sem erro: o app mostra "nenhuma obra encontrada" (não é erro).
  bool get isEmpty => !_loading && _error == null && _items.isEmpty;

  Future<void> load() async {
    final id = ++_requestId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _service.listBooks(
        query: _query,
        themeId: _themeId,
        educationLevelId: _levelId,
        sort: _sort,
      );
      if (id != _requestId) return;
      _items = list;
      onLoaded?.call(list);
    } on ApiException catch (e) {
      if (id != _requestId) return;
      _items = const [];
      _error = e;
    } catch (e, st) {
      if (id != _requestId) return;
      debugPrint('Falha inesperada ao listar obras: $e\n$st');
      _items = const [];
      _error = ApiException.unexpected('$e');
    }
    _loading = false;
    notifyListeners();
  }

  void setQuery(String value) {
    final trimmed = value.trim();
    if (trimmed == _query) return;
    _query = trimmed;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), load);
  }

  void setTheme(int? id) {
    if (id == _themeId) return;
    _themeId = id;
    load();
  }

  void setLevel(int? id) {
    if (id == _levelId) return;
    _levelId = id;
    load();
  }

  void setSort(BookSort sort) {
    if (sort == _sort) return;
    _sort = sort;
    load();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}