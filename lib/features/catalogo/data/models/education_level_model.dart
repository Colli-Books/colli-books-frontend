// features/catalogo/data/models/education_level_model.dart
class EducationLevelModel {
  const EducationLevelModel({required this.id, required this.name, this.sortOrder});

  final int id;
  final String name;
  final int? sortOrder; // só vem na listagem de escolaridades

  factory EducationLevelModel.fromJson(Map<String, dynamic> json) => EducationLevelModel(
    id: json['id'] as int,
    name: json['name'] as String,
    sortOrder: json['sort_order'] as int?,
  );
}