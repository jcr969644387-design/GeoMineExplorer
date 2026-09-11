import 'package:flutter_test/flutter_test.dart';
import 'package:geomine_explorer/data/datasources/settings_local_datasource.dart';
import 'package:geomine_explorer/data/repositories/settings_repository_impl.dart';
import 'package:geomine_explorer/domain/entities/app_settings.dart';

void main() {
  group('SettingsRepositoryImpl', () {
    test('sin datos guardados devuelve los valores por defecto', () async {
      final SettingsRepositoryImpl repository =
          SettingsRepositoryImpl(InMemorySettingsLocalDataSource());

      final AppSettings settings = await repository.load();

      expect(settings.soundEnabled, isTrue);
      expect(settings.hapticsEnabled, isTrue);
      // El tema por defecto es claro y no el del sistema: la primera versión
      // abría en oscuro en la mayoría de los teléfonos y las fichas de muestra
      // se leían mal.
      expect(settings.theme, ThemePreference.claro);
    });

    test('lo guardado se vuelve a leer igual', () async {
      final InMemorySettingsLocalDataSource source =
          InMemorySettingsLocalDataSource();
      final SettingsRepositoryImpl repository = SettingsRepositoryImpl(source);

      await repository.save(
        const AppSettings(
          soundEnabled: false,
          hapticsEnabled: true,
          theme: ThemePreference.oscuro,
        ),
      );
      final AppSettings restored = await repository.load();

      expect(restored.soundEnabled, isFalse);
      expect(restored.hapticsEnabled, isTrue);
      expect(restored.theme, ThemePreference.oscuro);
    });

    test('un tema desconocido cae al valor por defecto', () {
      // Protege contra un cambio de nombre del enum entre versiones: la app
      // debe arrancar, no reventar leyendo su propia preferencia.
      final AppSettings settings = AppSettings.fromJson(<String, dynamic>{
        'soundEnabled': true,
        'hapticsEnabled': false,
        'theme': 'neon',
      });

      expect(settings.theme, ThemePreference.claro);
      expect(settings.hapticsEnabled, isFalse);
    });
  });
}
