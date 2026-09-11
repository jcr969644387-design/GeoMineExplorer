import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// ViewModel de las preferencias.
///
/// A diferencia del avance no expone `AsyncValue`: la aplicacion debe poder
/// pintarse desde el primer fotograma con los valores por defecto y corregirse
/// cuando la lectura termina, en lugar de mostrar un indicador de carga por un
/// par de interruptores.
class SettingsViewModel extends StateNotifier<AppSettings> {
  SettingsViewModel(this._repository) : super(const AppSettings()) {
    load();
  }

  final SettingsRepository _repository;

  Future<void> load() async {
    try {
      state = await _repository.load();
    } catch (error) {
      state = const AppSettings();
    }
  }

  Future<void> setSoundEnabled(bool value) =>
      _update(state.copyWith(soundEnabled: value));

  Future<void> setHapticsEnabled(bool value) =>
      _update(state.copyWith(hapticsEnabled: value));

  Future<void> setTheme(ThemePreference value) =>
      _update(state.copyWith(theme: value));

  Future<void> _update(AppSettings settings) async {
    state = settings;
    try {
      await _repository.save(settings);
    } catch (error) {
      // Que falle el guardado no debe revertir la eleccion en pantalla: el
      // ajuste sigue activo en esta sesion aunque no sobreviva al cierre.
      return;
    }
  }
}
