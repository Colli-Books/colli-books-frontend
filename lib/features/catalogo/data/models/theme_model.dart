// features/catalogo/data/models/theme_model.dart
class ThemeModel {
  const ThemeModel({required this.id, required this.name, this.description});

  final int id;
  final String name;
  final String? description; // só vem na listagem de temas, não nos resumos de obra

  factory ThemeModel.fromJson(Map<String, dynamic> json) => ThemeModel(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String?,
  );
}