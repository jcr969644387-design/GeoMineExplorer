/// Identidad y version de la aplicacion.
///
/// Un unico sitio donde vive el nombre visible y el numero de version. La
/// numeracion es consecutiva por entrega (GeoMineExplorerV1.0.1, V1.0.2, ...)
/// y debe coincidir en tres lugares: este archivo, el campo `version` de
/// pubspec.yaml y el mensaje del commit. Ver docs/09_versionado.md.
abstract class AppInfo {
  /// Nombre visible. Nunca se muestra el identificador del paquete.
  static const String name = 'GeoMine Explorer';

  static const String version = '1.0.1';

  /// Etiqueta de la entrega; es tambien el nombre del APK publicado.
  static const String release = 'GeoMineExplorerV$version';

  static const String tagline = 'Laboratorio geológico de bolsillo para '
      'Ingeniería de Minas';
}
