// lib/features/admin/data/models/teacher_model.dart

enum TeacherStatus {
  invitePending('invite_pending'),
  active('active'),
  inactive('inactive'),
  unknown('');

  const TeacherStatus(this.apiValue);

  /// Valor usado pela API (também aceito no filtro `status` de GET /admin/teachers).
  final String apiValue;

  /// Um status novo no backend não pode derrubar a listagem inteira.
  static TeacherStatus fromApi(String? value) => TeacherStatus.values.firstWhere(
        (s) => s != TeacherStatus.unknown && s.apiValue == value,
    orElse: () => TeacherStatus.unknown,
  );

  String get label => switch (this) {
    TeacherStatus.invitePending => 'Convite pendente',
    TeacherStatus.active => 'Ativo',
    TeacherStatus.inactive => 'Inativo',
    TeacherStatus.unknown => 'Desconhecido',
  };
}

/// Item de GET /admin/teachers (UserResponse da API).
class TeacherModel {
  const TeacherModel({
    required this.id,
    required this.email,
    required this.status,
    this.fullName,
    this.school,
  });

  final int id;
  final String email;
  final String? fullName; // null enquanto o convite está pendente
  final String? school;
  final TeacherStatus status;

  /// Nome para exibição; cai para o e-mail quando o professor ainda não se cadastrou.
  String get displayName => (fullName?.trim().isNotEmpty ?? false) ? fullName! : email;

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
    id: json['id'] as int,
    email: json['email'] as String,
    fullName: json['full_name'] as String?,
    school: json['school'] as String?,
    status: TeacherStatus.fromApi(json['status'] as String?),
  );
}