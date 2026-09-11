/// Tema visual elegido por el estudiante.
///
/// El valor por defecto es claro y no "segun el sistema": la aplicacion se usa
/// sobre todo de dia, en aula y laboratorio, y arrancar en oscuro hacia que las
/// fichas de muestra (que llevan color propio) se leyeran mal.
enum ThemePreference {
  claro('Claro'),
  oscuro('Oscuro'),
  sistema('Según el sistema');

  const ThemePreference(this.label);

  final String label;

  static ThemePreference fromKey(String? key) {
    for (final ThemePreference value in ThemePreference.values) {
      if (value.name == key) {
        return value;
      }
    }
    return ThemePreference.claro;
  }
}

/// Preferencias de la aplicacion que el estudiante controla.
class AppSettings {
  const AppSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.theme = ThemePreference.claro,
  });

  /// Tonos cortos al confirmar, acertar, fallar y cerrar una sesion.
  final bool soundEnabled;

  /// Vibracion breve en las mismas acciones.
  final bool hapticsEnabled;
  final ThemePreference theme;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    ThemePreference? theme,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'theme': theme.name,
      };

  static AppSettings fromJson(Map<String, dynamic> json) {
    return AppSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      theme: ThemePreference.fromKey(json['theme'] as String?),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.soundEnabled == soundEnabled &&
      other.hapticsEnabled == hapticsEnabled &&
      other.theme == theme;

  @override
  int get hashCode => Object.hash(soundEnabled, hapticsEnabled, theme);
}
