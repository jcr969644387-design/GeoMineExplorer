import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Contenedor base de la aplicacion.
///
/// Se define a mano en lugar de usar `Card` para controlar radio, borde y
/// sombra sin depender de `CardTheme`, cuya API cambio entre versiones de
/// Flutter. La sombra solo se dibuja en tema claro: sobre fondo oscuro una
/// sombra negra no se ve y solo ensucia el dibujado.
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final BorderRadius radius = BorderRadius.circular(GeoSpacing.cardRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: isDark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: GeoPalette.graphite.withValues(alpha: 0.055),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: scheme.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: scheme.outline.withValues(alpha: isDark ? 1 : 0.8),
              ),
            ),
            child: _AccentedContent(
              accentColor: accentColor,
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Contenido de la tarjeta con la franja de color lateral.
///
/// Se dibuja con un [Stack] y no con una fila estirada. La version anterior
/// usaba `Row(crossAxisAlignment: stretch)`, que exige conocer la altura de
/// antemano: dentro de una lista —donde la altura no esta acotada— eso propaga
/// una altura infinita. En depuracion lanza "BoxConstraints forces an infinite
/// height" y en release, sin aserciones, la tarjeta ocupaba un alto infinito y
/// empujaba fuera de la pantalla todo lo que venia detras. Aqui la altura la
/// fija el contenido y la franja se posiciona contra esa altura ya resuelta.
class _AccentedContent extends StatelessWidget {
  const _AccentedContent({
    required this.accentColor,
    required this.padding,
    required this.child,
  });

  final Color? accentColor;
  final EdgeInsetsGeometry padding;
  final Widget child;

  static const double _stripeWidth = 5;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(padding: padding, child: child);
    final Color? accent = accentColor;
    if (accent == null) {
      return content;
    }
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: _stripeWidth),
          child: content,
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          width: _stripeWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(GeoSpacing.cardRadius - 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Etiqueta compacta para metadatos (grupo mineral, tipo de roca, dificultad).
class GeoTag extends StatelessWidget {
  const GeoTag({super.key, required this.label, this.color, this.icon});

  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color base = color ?? GeoPalette.slate;
    final TextStyle? style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: base,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: base),
            const SizedBox(width: 5),
          ],
          Text(label, style: style),
        ],
      ),
    );
  }
}

/// Insignia cuadrada con icono, usada como ancla visual de cada tarjeta.
///
/// Sustituye a las listas de texto plano de la primera version: un icono con
/// color propio permite reconocer la seccion antes de leer el titulo.
class GeoIconBadge extends StatelessWidget {
  const GeoIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.filled = false,
  });

  final IconData icon;
  final Color color;
  final double size;

  /// Si el fondo va en color solido en lugar de teñido.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: filled ? Colors.white : color,
      ),
    );
  }
}

/// Encabezado de seccion dentro de una pantalla.
class GeoSectionHeader extends StatelessWidget {
  const GeoSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Tarjeta de seccion de una ficha, con icono y color propios.
///
/// Las fichas del catalogo son largas y todas sus secciones se parecian entre
/// si. El icono y la franja de color permiten saltar directamente a la parte
/// que interesa sin leer los titulos.
class GeoDetailCard extends StatelessWidget {
  const GeoDetailCard({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GeoCard(
      accentColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              GeoIconBadge(icon: icon, color: accent, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Estado vacio o de error con icono, titulo y explicacion.
class GeoMessage extends StatelessWidget {
  const GeoMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color base = color ?? GeoPalette.slate;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GeoIconBadge(icon: icon, color: base, size: 62),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
