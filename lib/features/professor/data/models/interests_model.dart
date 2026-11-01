import '../../../catalogo/data/models/education_level_model.dart';
import '../../../catalogo/data/models/theme_model.dart';

/// Resposta de PUT /me/interests.
class InterestsModel {
  const InterestsModel({required this.themes, required this.educationLevels});

  final List<ThemeModel> themes;
  final List<EducationLevelModel> educationLevels;

  factory InterestsModel.fromJson(Map<String, dynamic> json) => InterestsModel(
    themes: [
      for (final t in json['themes'] as List) ThemeModel.fromJson(t as Map<String, dynamic>),
    ],
    educationLevels: [
      for (final l in json['education_levels'] as List)
        EducationLevelModel.fromJson(l as Map<String, dynamic>),
    ],
  );
}