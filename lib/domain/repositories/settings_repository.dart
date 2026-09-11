import '../entities/app_settings.dart';

/// Acceso a las preferencias del estudiante.
abstract class SettingsRepository {
  Future<AppSettings> load();

  Future<AppSettings> save(AppSettings settings);
}
