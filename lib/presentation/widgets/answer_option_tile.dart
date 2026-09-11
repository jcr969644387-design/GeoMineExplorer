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

    Color borderColor = theme.colorScheme.outline;
    Color background = theme.colorScheme.surface;
    IconData? icon;
    Color? iconColor;

    if (revealed) {
      if (option.correct) {
        borderColor = GeoPalette.malachite;
        background = GeoPalette.malachite.withValues(alpha: 0.08);
        icon = Icons.check_circle_outline;
        iconColor = GeoPalette.malachite;
      } else if (selected) {
        borderColor = GeoPalette.hematite;
        background = GeoPalette.hematite.withValues(alpha: 0.08);
        icon = Icons.cancel_outlined;
        iconColor = GeoPalette.hematite;
      }
    } else if (selected) {
      borderColor = theme.colorScheme.primary;
      background = theme.colorScheme.primary.withValues(alpha: 0.06);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: revealed ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
                width: selected || (revealed && option.correct) ? 1.6 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(option.text, style: theme.textTheme.bodyMedium),
                ),
                if (icon != null) ...<Widget>[
                  const SizedBox(width: 10),
                  Icon(icon, size: 20, color: iconColor),
                ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            correct ? 'Razonamiento correcto' : 'Revisa este razonamiento',
            style: theme.textTheme.titleSmall?.copyWith(color: accent),
          ),
          const SizedBox(height: 8),
          Text(explanation, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
