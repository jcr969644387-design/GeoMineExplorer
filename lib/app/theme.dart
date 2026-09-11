import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta derivada del propio dominio: verde malaquita como color de accion,
/// amarillo pirita como acento de atencion y rojo hematita para el error.
///
/// Respecto de la primera version se aclaro el fondo y se añadieron los tonos
/// vivos (malachiteLight, mint, pyriteLight) que alimentan los degradados. La
/// aplicacion la usan estudiantes entre clases, no es una consola de
/// operaciones: un gris plano de extremo a extremo la hacia parecer apagada.
abstract class GeoPalette {
  static const Color malachite = Color(0xFF0F7D64);
  static const Color malachiteLight = Color(0xFF2FB68F);
  static const Color mint = Color(0xFF7FE3C4);
  static const Color deepTeal = Color(0xFF0D2A31);
  static const Color pyrite = Color(0xFFC08A05);
  static const Color pyriteLight = Color(0xFFF2C744);
  static const Color hematite = Color(0xFFB0392E);
  static const Color azurite = Color(0xFF2F6FB6);
  static const Color graphite = Color(0xFF101A1F);
  static const Color slate = Color(0xFF55636E);
  static const Color stone = Color(0xFFEFF4F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFDCE4E1);
  static const Color darkScaffold = Color(0xFF0A1013);
  static const Color darkSurface = Color(0xFF141C21);
  static const Color darkOutline = Color(0xFF2A353C);
}

/// Degradados de marca.
///
/// Se centralizan para que la cabecera, las insignias y el icono no acaben
/// dibujando cada uno su propia interpretacion del verde de la aplicacion.
abstract class GeoGradients {
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[GeoPalette.deepTeal, GeoPalette.malachite],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[GeoPalette.malachite, GeoPalette.malachiteLight],
  );

  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[GeoPalette.pyriteLight, GeoPalette.pyrite],
  );
}

/// Medidas compartidas: radios y separaciones.
///
/// Un unico juego de constantes evita el efecto "cada pantalla con su propio
/// margen" que hacia ver desordenada la version anterior.
abstract class GeoSpacing {
  static const double gutter = 18;
  static const double cardRadius = 20;
  static const double chipRadius = 12;
}

abstract class GeoTheme {
  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: GeoPalette.malachite,
    ).copyWith(
      primary: GeoPalette.malachite,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD5F1E7),
      onPrimaryContainer: const Color(0xFF063A2D),
      secondary: GeoPalette.pyrite,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFBEEC8),
      onSecondaryContainer: const Color(0xFF4A3703),
      tertiary: GeoPalette.azurite,
      onTertiary: Colors.white,
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
      primary: const Color(0xFF4FD6AE),
      onPrimary: const Color(0xFF04261D),
      primaryContainer: const Color(0xFF0E4738),
      onPrimaryContainer: GeoPalette.mint,
      secondary: GeoPalette.pyriteLight,
      onSecondary: const Color(0xFF3A2A00),
      secondaryContainer: const Color(0xFF4A3703),
      onSecondaryContainer: const Color(0xFFFBEEC8),
      tertiary: const Color(0xFF7FB2EE),
      onTertiary: const Color(0xFF06253F),
      error: const Color(0xFFE79086),
      onError: const Color(0xFF3B0B06),
      surface: GeoPalette.darkSurface,
      onSurface: const Color(0xFFE7ECEA),
      outline: GeoPalette.darkOutline,
    );
    return _build(scheme, GeoPalette.darkScaffold);
  }

  static ThemeData _build(ColorScheme scheme, Color scaffoldColor) {
    final bool isDark = scheme.brightness == Brightness.dark;
    final Typography typography =
        Typography.material2021(platform: TargetPlatform.android);
    final TextTheme base = (isDark ? typography.white : typography.black).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    final Color muted = scheme.onSurface.withValues(alpha: 0.66);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldColor,
      textTheme: base.copyWith(
        headlineMedium: base.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
        titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: base.bodyLarge?.copyWith(height: 1.45),
        bodyMedium: base.bodyMedium?.copyWith(height: 1.5),
        bodySmall: base.bodySmall?.copyWith(
          fontSize: 13,
          height: 1.45,
          color: muted,
        ),
        labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        labelSmall: base.labelSmall?.copyWith(letterSpacing: 0.2),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldColor,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: GeoSpacing.gutter,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: base.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: scheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: isDark ? GeoPalette.darkSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.15),
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        // Seis destinos no caben con la tipografia por defecto en un telefono
        // de 360 dp: se reduce el cuerpo de la etiqueta en lugar de recortar
        // nombres que el estudiante necesita leer completos.
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) => TextStyle(
            fontSize: 10.5,
            letterSpacing: 0,
            height: 1.1,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) => IconThemeData(
            size: 22,
            color:
                states.contains(WidgetState.selected) ? scheme.primary : muted,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        backgroundColor:
            isDark ? Colors.white.withValues(alpha: 0.05) : GeoPalette.stone,
        selectedColor: scheme.primary,
        side: BorderSide(color: scheme.outline),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GeoSpacing.chipRadius),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.14),
        circularTrackColor: scheme.primary.withValues(alpha: 0.14),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 1,
        space: 1,
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
