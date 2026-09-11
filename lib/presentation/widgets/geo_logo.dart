import 'package:flutter/material.dart';

/// Marca de la aplicacion: el cristal facetado del icono.
///
/// Se dibuja desde el mismo PNG que genera el icono del lanzador, para que lo
/// que el estudiante ve en el escritorio y lo que ve dentro de la aplicacion
/// sean la misma pieza. Si el bundle de assets no esta disponible (por ejemplo
/// en una prueba de widget) se sustituye por un icono equivalente en lugar de
/// dejar que la carga falle y ensucie la salida.
class GeoLogo extends StatelessWidget {
  const GeoLogo({super.key, this.size = 32, this.fallbackColor});

  final double size;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icon/logo_mark.png',
      width: size,
      height: size,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return Icon(
          Icons.diamond_outlined,
          size: size,
          color: fallbackColor ?? Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}
