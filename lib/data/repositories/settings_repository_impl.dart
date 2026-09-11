import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dataSource);

  final SettingsLocalDataSource _dataSource;

  @override
  Future<AppSettings> load() async {
    final Map<String, dynamic>? raw = await _dataSource.read();
    if (raw == null) {
      return const AppSettings();
    }
    return AppSettings.fromJson(raw);
  }

  @override
  Future<AppSettings> save(AppSettings settings) async {
    await _dataSource.write(settings.toJson());
    return settings;
  }
}
