import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/exercise.dart';
import '../providers.dart';
import '../viewmodels/practice_view_model.dart';
import '../widgets/answer_option_tile.dart';
import '../widgets/geo_card.dart';

/// Pantalla de practica situacional.
///
/// Cada ejercicio abre con una escena de trabajo antes del enunciado: el
/// objetivo no es responder un examen sino decidir dentro de un contexto.
class PracticeView extends ConsumerStatefulWidget {
  const PracticeView({super.key});

  @override
  ConsumerState<PracticeView> createState() => _PracticeViewState();
}

class _PracticeViewState extends ConsumerState<PracticeView> {
  bool _started = false;

  Future<void> _start(ExerciseModule? module) async {
    setState(() => _started = true);
    await ref.read(practiceProvider.notifier).start(module: module);
  }

  Future<void> _confirm(Exercise exercise) async {
    final bool correct = ref.read(practiceProvider.notifier).confirm();
    await ref.read(progressProvider.notifier).recordAttempt(
          itemId: exercise.id,
          competency: exercise.competency,
          correct: correct,
        );
  }

  @override
  Widget build(BuildContext context) {
    final PracticeState state = ref.watch(practiceProvider);

    if (!_started) {
      return _ModulePicker(onPick: _start);
    }
    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Práctica')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudieron cargar los ejercicios.\n'
                '${state.error}'),
          ),
        ),
      );
    }
    if (!state.hasExercises) {
      return Scaffold(
        appBar: AppBar(title: const Text('Práctica')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No hay ejercicios disponibles para este módulo.'),
          ),
        ),
      );
    }
    if (state.isFinished) {
      return _SessionSummary(
        correct: state.correctCount,
        total: state.total,
        onRestart: () => setState(() => _started = false),
      );
    }

    final Exercise exercise = state.current!;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${state.index + 1} de ${state.total}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: state.completion,
            minHeight: 3,
            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GeoTag(
                label: 'Nivel ${exercise.difficulty}',
                color: GeoPalette.slate,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          GeoCard(
            accentColor: GeoPalette.slate,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(exercise.context,
                      style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(exercise.stem, style: theme.textTheme.titleMedium),
          const SizedBox(height: 18),
          ...exercise.options.map(
            (ExerciseOption option) => AnswerOptionTile(
              option: option,
              selected: state.selectedOptionId == option.id,
              revealed: state.answered,
              onTap: () =>
                  ref.read(practiceProvider.notifier).select(option.id),
            ),
          ),
          const SizedBox(height: 8),
          if (state.answered) ...<Widget>[
            ExplanationPanel(
              correct: exercise.isCorrect(state.selectedOptionId ?? ''),
              explanation: exercise.explanation,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: ref.read(practiceProvider.notifier).next,
              child: Text(state.index + 1 >= state.total
                  ? 'Ver resultado'
                  : 'Siguiente'),
            ),
          ] else
            FilledButton(
              onPressed: state.selectedOptionId == null
                  ? null
                  : () => _confirm(exercise),
              child: const Text('Confirmar respuesta'),
            ),
        ],
      ),
    );
  }
}

/// Seleccion del modulo de practica.
class _ModulePicker extends StatelessWidget {
  const _ModulePicker({required this.onPick});

  final void Function(ExerciseModule?) onPick;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Práctica')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text(
            'Sesiones de ocho ejercicios. Los que fallaste antes vuelven a '
            'aparecer primero.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          GeoCard(
            accentColor: GeoPalette.malachite,
            onTap: () => onPick(null),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Sesión mixta', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Minerales, rocas y estructuras combinados',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Por módulo', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          ...ExerciseModule.values.map(
            (ExerciseModule module) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GeoCard(
                onTap: () => onPick(module),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(module.label,
                          style: theme.textTheme.bodyLarge),
                    ),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Resumen de cierre de la sesion.
class _SessionSummary extends StatelessWidget {
  const _SessionSummary({
    required this.correct,
    required this.total,
    required this.onRestart,
  });

  final int correct;
  final int total;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double ratio = total == 0 ? 0 : correct / total;
    final String message = ratio >= 0.8
        ? 'Criterio consolidado en esta selección de ejercicios.'
        : (ratio >= 0.5
            ? 'Base correcta, con confusiones puntuales todavía activas.'
            : 'Conviene repasar las fichas antes de la siguiente sesión: los '
                'errores se concentran en propiedades diagnósticas.');

    return Scaffold(
      appBar: AppBar(title: const Text('Sesión completada')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('$correct de $total',
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRestart,
              child: const Text('Nueva sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
