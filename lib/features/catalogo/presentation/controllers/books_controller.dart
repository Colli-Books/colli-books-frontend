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
  Set<int> _themeIds = const {};
  Set<int> _levelIds = const {};
  BookSort _sort = BookSort.relevance;
  Timer? _debounce;
  int _requestId = 0;
  bool _disposed = false;

  List<BookSummary> get items => _items;
  bool get isLoading => _loading;
  ApiException? get error => _error;
  /// Filtro por temas: a obra entra se tiver qualquer um deles. Vazio = todos.
  Set<int> get themeIds => _themeIds;

  /// Filtro por escolaridades: a obra entra se tiver qualquer uma. Vazio = todas.
  Set<int> get levelIds => _levelIds;
  BookSort get sort => _sort;
  bool get hasFilters => _query.isNotEmpty || _themeIds.isNotEmpty || _levelIds.isNotEmpty;

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
        themeIds: _themeIds,
        educationLevelIds: _levelIds,
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

  void setThemes(Set<int> ids) {
    if (setEquals(ids, _themeIds)) return;
    _themeIds = Set.unmodifiable(ids);
    load();
  }

  void setLevels(Set<int> ids) {
    if (setEquals(ids, _levelIds)) return;
    _levelIds = Set.unmodifiable(ids);
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