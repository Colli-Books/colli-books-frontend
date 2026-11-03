// features/catalogo/presentation/controllers/catalog_options_controller.dart
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/education_level_model.dart';
import '../../data/models/theme_model.dart';
import '../../data/services/catalog_api_service.dart';

/// Temas + escolaridades para pickers de formulário e chips de filtro.
class CatalogOptionsController extends ChangeNotifier {
  CatalogOptionsController(this._service);

  final CatalogApiService _service;

  List<ThemeModel> _themes = const [];
  List<EducationLevelModel> _levels = const [];
  bool _loading = false;
  ApiException? _error;
  bool _disposed = false;

  List<ThemeModel> get themes => _themes;
  List<EducationLevelModel> get levels => _levels;
  bool get isLoading => _loading;
  ApiException? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await Future.wait<Object>([
        _service.listThemes(),
        _service.listEducationLevels(),
      ]);
      _themes = r[0] as List<ThemeModel>;
      _levels = r[1] as List<EducationLevelModel>;
    } on ApiException catch (e) {
      _error = e;
    } catch (e, st) {
      debugPrint('Falha inesperada ao carregar opções: $e\n$st');
      _error = ApiException.unexpected('$e');
    }
    _loading = false;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}