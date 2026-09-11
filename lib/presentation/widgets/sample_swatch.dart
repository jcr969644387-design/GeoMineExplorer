import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/entities/mineral.dart';

/// Representacion esquematica de una muestra.
///
/// No pretende sustituir una fotografia: dibuja color y brillo para que la
/// ficha tenga un ancla visual. El catalogo fotografico validado por el docente
/// es una tarea de la version 2 (ver docs/04_mvp.md).
class SampleSwatch extends StatelessWidget {
  const SampleSwatch({
    super.key,
    required this.hexColor,
    required this.metallic,
    this.size = 48,
  });

  final String hexColor;
  final bool metallic;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color base = parseHexColor(hexColor);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7),
        ),
        gradient: metallic
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color.lerp(base, Colors.white, 0.45)!,
                  base,
                  Color.lerp(base, Colors.black, 0.35)!,
                  Color.lerp(base, Colors.white, 0.2)!,
                ],
                stops: const <double>[0.0, 0.35, 0.7, 1.0],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color.lerp(base, Colors.white, 0.12)!,
                  base,
                ],
              ),
      ),
    );
  }

  /// Constructor de conveniencia a partir de un mineral.
  static SampleSwatch forMineral(Mineral mineral, {double size = 48}) {
    return SampleSwatch(
      hexColor: mineral.displayColor,
      metallic: mineral.luster == LusterType.metalico,
      size: size,
    );
  }
}
