import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/teacher_model.dart';
import '../../data/services/admin_api_service.dart';

class TeachersController extends ChangeNotifier {
  TeachersController(this._service);

  final AdminApiService _service;

  List<TeacherModel> _all = const [];
  bool _loading = false;
  ApiException? _error;
  TeacherStatus? _status; // null = todos
  String _query = '';
  Timer? _debounce;
  int _requestId = 0; // descarta respostas de requisições antigas
  bool _disposed = false;

  /// Lista já filtrada pela aba atual.
  List<TeacherModel> get items =>
      _status == null ? _all : [for (final t in _all) if (t.status == _status) t];

  bool get isLoading => _loading;
  ApiException? get error => _error;
  TeacherStatus? get status => _status;
  bool get isEmpty => !_loading && _error == null && items.isEmpty;

  /// Contador para as abas (null = todos). Reflete a busca atual.
  int countOf(TeacherStatus? s) =>
      s == null ? _all.length : _all.where((t) => t.status == s).length;

  Future<void> load() async {
    final id = ++_requestId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _service.listTeachers(query: _query);
      if (id != _requestId) return;
      _all = list;
    } on ApiException catch (e) {
      if (id != _requestId) return;
      _all = const [];
      _error = e;
    } catch (e, st) {
      if (id != _requestId) return;
      debugPrint('Falha inesperada ao listar professores: $e\n$st');
      _all = const [];
      _error = ApiException.unexpected('$e');
    }
    _loading = false;
    notifyListeners();
  }

  void setStatus(TeacherStatus? status) {
    if (status == _status) return;
    _status = status;
    notifyListeners();
  }

  void setQuery(String value) {
    final trimmed = value.trim();
    if (trimmed == _query) return;
    _query = trimmed;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), load);
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