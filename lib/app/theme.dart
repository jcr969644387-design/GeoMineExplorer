import 'package:flutter/material.dart';

/// Paleta derivada del propio dominio: verde malaquita como color de accion,
/// amarillo pirita como acento de atencion y rojo hematita para el error.
/// La base es un gris mineral frio, no un crema neutro, para que las fichas de
/// muestra (que llevan color propio) no compitan con el fondo.
abstract class GeoPalette {
  static const Color malachite = Color(0xFF1F7A63);
  static const Color malachiteDark = Color(0xFF145043);
  static const Color pyrite = Color(0xFFC9A227);
  static const Color hematite = Color(0xFF8C2F2A);
  static const Color graphite = Color(0xFF1B2026);
  static const Color slate = Color(0xFF4A545E);
  static const Color stone = Color(0xFFEDEFF1);
  static const Color surface = Color(0xFFFAFBFC);
  static const Color outline = Color(0xFFD3D8DD);
}

abstract class GeoTheme {
  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: GeoPalette.malachite,
    ).copyWith(
      primary: GeoPalette.malachite,
      onPrimary: Colors.white,
      secondary: GeoPalette.pyrite,
      onSecondary: GeoPalette.graphite,
      error: GeoPalette.hematite,
      onError: Colors.white,
      surface: GeoPalette.surface,
      onSurface: GeoPalette.graphite,
      outline: GeoPalette.outline,
    );
    return _build(scheme, GeoPalette.stone);
  }

  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: GeoPalette.malachite,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF63C6AB),
      secondary: GeoPalette.pyrite,
      error: const Color(0xFFE08C86),
      surface: const Color(0xFF161A1F),
      onSurface: const Color(0xFFE6E9EC),
    );
    return _build(scheme, const Color(0xFF0F1216));
  }

  static ThemeData _build(ColorScheme scheme, Color scaffoldColor) {
    final Typography typography =
        Typography.material2021(platform: TargetPlatform.android);
    final TextTheme base =
        (scheme.brightness == Brightness.dark ? typography.white : typography.black)
            .apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldColor,
      textTheme: base.copyWith(
        headlineSmall: base.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: scheme.onSurface,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: scheme.onSurface,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
        bodySmall: base.bodySmall?.copyWith(height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldColor,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerColor: scheme.outline,
      splashFactory: InkSparkle.splashFactory,
    );
  }
}

/// Convierte un color hexadecimal del catalogo (#RRGGBB) en un [Color].
Color parseHexColor(String hex, {Color fallback = GeoPalette.slate}) {
  final String cleaned = hex.replaceAll('#', '').trim();
  if (cleaned.length != 6) {
    return fallback;
  }
  final int? value = int.tryParse(cleaned, radix: 16);
  if (value == null) {
    return fallback;
  }
  return Color(0xFF000000 | value);
}
