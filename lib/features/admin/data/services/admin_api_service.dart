import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_helpers.dart';
import '../models/admin_overview_model.dart';
import '../models/invite_result_model.dart';
import '../models/teacher_model.dart';

class AdminApiService {
  AdminApiService(this._api);

  final ApiClient _api;

  /// POST /admin/teachers. Erros: EMAIL_ALREADY_REGISTERED, VALIDATION_ERROR, FORBIDDEN.
  Future<InviteResultModel> createTeacher(String email) async {
    final json = asJsonMap(await _api.post('/admin/teachers', body: {'email': email.trim()}));
    return parseResponse(() => InviteResultModel.fromJson(json));
  }

  /// POST /admin/teachers/{id}/invite. Erros: NOT_FOUND, ACCOUNT_ALREADY_ACTIVE.
  Future<InviteResultModel> resendInvite(int teacherId) async {
    final json = asJsonMap(await _api.post('/admin/teachers/$teacherId/invite'));
    return parseResponse(() => InviteResultModel.fromJson(json));
  }

  /// GET /admin/teachers: lista completa (sem paginação). `q` busca por nome/e-mail.
  Future<List<TeacherModel>> listTeachers({String? query}) async {
    final q = query?.trim() ?? '';
    final raw = await _api.get(
      '/admin/teachers',
      queryParameters: {'q': q.isEmpty ? null : q},
    );
    return parseResponse(() => [
      for (final e in asJsonList(raw)) TeacherModel.fromJson(e as Map<String, dynamic>),
    ]);
  }

  /// GET /admin/overview.
  Future<AdminOverviewModel> fetchOverview() async {
    final json = asJsonMap(await _api.get('/admin/overview'));
    return parseResponse(() => AdminOverviewModel.fromJson(json));
  }
}