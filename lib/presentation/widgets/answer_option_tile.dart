import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/entities/exercise.dart';

/// Alternativa de respuesta con estados de seleccion y correccion.
///
/// Tras confirmar se marca tanto lo elegido como lo correcto: ver la respuesta
/// correcta junto al propio error es lo que convierte un fallo en aprendizaje.
class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.revealed,
    required this.onTap,
  });

  final ExerciseOption option;
  final bool selected;

  /// Si ya se confirmo la respuesta y corresponde mostrar el resultado.
  final bool revealed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    Color borderColor = theme.colorScheme.outline;
    Color background = theme.colorScheme.surface;
    Color markColor = theme.colorScheme.outline;
    IconData? icon;
    double borderWidth = 1;

    // El tinte del fondo sube en tema oscuro: sobre superficie casi negra un
    // 7 % de color no se distingue.
    final double tint = isDark ? 0.16 : 0.07;

    if (revealed) {
      if (option.correct) {
        borderColor = GeoPalette.malachite;
        background = GeoPalette.malachite.withValues(alpha: tint);
        markColor = GeoPalette.malachite;
        icon = Icons.check;
        borderWidth = 1.8;
      } else if (selected) {
        borderColor = GeoPalette.hematite;
        background = GeoPalette.hematite.withValues(alpha: tint);
        markColor = GeoPalette.hematite;
        icon = Icons.close;
        borderWidth = 1.8;
      }
    } else if (selected) {
      borderColor = theme.colorScheme.primary;
      background = theme.colorScheme.primary.withValues(alpha: 0.07);
      markColor = theme.colorScheme.primary;
      icon = Icons.circle;
      borderWidth = 1.8;
    }

    final BorderRadius radius = BorderRadius.circular(16);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          onTap: revealed ? null : onTap,
          borderRadius: radius,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: icon == null
                        ? Colors.transparent
                        : markColor.withValues(alpha: 0.16),
                    border: Border.all(color: markColor, width: 1.6),
                  ),
                  child: icon == null
                      ? null
                      : Icon(
                          icon,
                          size: icon == Icons.circle ? 10 : 14,
                          color: markColor,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(option.text, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Panel de explicacion mostrado tras responder.
class ExplanationPanel extends StatelessWidget {
  const ExplanationPanel({
    super.key,
    required this.correct,
    required this.explanation,
  });

  final bool correct;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = correct ? GeoPalette.malachite : GeoPalette.hematite;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(GeoSpacing.cardRadius),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                correct ? Icons.verified_outlined : Icons.lightbulb_outline,
                size: 18,
                color: accent,
              ),
              const SizedBox(width: 8),
              Text(
                correct ? 'Razonamiento correcto' : 'Revisa este razonamiento',
                style: theme.textTheme.titleSmall?.copyWith(color: accent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(explanation, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
