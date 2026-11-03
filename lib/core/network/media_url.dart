import '../config/app_config.dart';

String? resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  return Uri.parse(AppConfig.apiBaseUrl).resolve(path).toString();
}