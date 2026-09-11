import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Contenedor base de la aplicacion.
///
/// Se define a mano en lugar de usar `Card` para controlar radio y borde sin
/// depender de `CardTheme`, cuya API cambio entre versiones de Flutter.
class GeoCard extends StatelessWidget {
  const GeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accentColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Franja lateral de color; se usa para codificar categorias.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(12);

    // El InkWell va por encima del relleno (Material + Ink) para que la
    // realimentacion tactil sea visible en las tarjetas pulsables.
    return Material(
      color: scheme.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (accentColor != null)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(11),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(padding: padding, child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Etiqueta compacta para metadatos (grupo mineral, tipo de roca, dificultad).
class GeoTag extends StatelessWidget {
  const GeoTag({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color base = color ?? GeoPalette.slate;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: base,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
