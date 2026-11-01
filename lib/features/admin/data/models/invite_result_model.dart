// lib/features/admin/data/models/invite_result_model.dart

import 'teacher_model.dart';

/// Resposta de POST /admin/teachers e POST /admin/teachers/{id}/invite.
class InviteResultModel {
  const InviteResultModel({
    required this.id,
    required this.email,
    required this.status,
    required this.inviteLink,
    required this.inviteCode,
    required this.inviteExpiresAt,
  });

  final int id;
  final String email;
  final TeacherStatus status;
  final String inviteLink; // collibooks://convite?token=...  (SEGREDO)
  final String inviteCode; // mesmo token, para colar no app  (SEGREDO)
  final DateTime inviteExpiresAt; // UTC; use .toLocal() para exibir

  factory InviteResultModel.fromJson(Map<String, dynamic> json) => InviteResultModel(
    id: json['id'] as int,
    email: json['email'] as String,
    status: TeacherStatus.fromApi(json['status'] as String?),
    inviteLink: json['invite_link'] as String,
    inviteCode: json['invite_code'] as String,
    inviteExpiresAt: DateTime.parse(json['invite_expires_at'] as String),
  );

  /// Evita vazar link/código se alguém der print() no objeto.
  @override
  String toString() => 'InviteResultModel(id: $id, email: $email)';
}