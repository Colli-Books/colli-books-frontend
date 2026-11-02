import '../../../../core/network/api_exception.dart';

enum UserRole { teacher, admin }

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.fullName,
    this.school,
  });

  final int id;
  final String email;
  final String? fullName; // pode ser null (ex.: convite pendente)
  final String? school;
  final UserRole role;
  final String status; // 'active' | 'invite_pending' | 'inactive'

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final role = switch (json['role']) {
      'teacher' => UserRole.teacher,
      'admin' => UserRole.admin,
      final other => throw ApiException.unexpected('Papel desconhecido: $other'),
    };
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      school: json['school'] as String?,
      role: role,
      status: json['status'] as String,
    );
  }
}