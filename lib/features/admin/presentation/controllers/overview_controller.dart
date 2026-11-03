import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/admin_overview_model.dart';
import '../../data/services/admin_api_service.dart';

class OverviewController extends ChangeNotifier {
  OverviewController(this._service);

  final AdminApiService _service;

  AdminOverviewModel? _data;
  ApiException? _error;
  bool _loading = false;
  bool _disposed = false;

  AdminOverviewModel? get data => _data; // mantém o último valor num refresh com erro
  ApiException? get error => _error;
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _service.fetchOverview();
    } on ApiException catch (e) {
      _error = e;
    } catch (e, st) {
      debugPrint('Falha inesperada no overview: $e\n$st');
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