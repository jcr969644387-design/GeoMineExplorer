import 'package:flutter/material.dart';

/// Fila etiqueta-valor usada en las fichas del catalogo.
class PropertyRow extends StatelessWidget {
  const PropertyRow({
    super.key,
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;

  /// Marca las propiedades diagnosticas, las que resuelven la identificacion.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
                color: highlighted ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista con viñetas usada para criterios de reconocimiento.
class BulletList extends StatelessWidget {
  const BulletList({super.key, required this.items, this.bulletColor});

  final List<String> items;
  final Color? bulletColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (String item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 10),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bulletColor ?? theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(item, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
