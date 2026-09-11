import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/exercise.dart';
import '../providers.dart';
import '../services/feedback_service.dart';
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
    ref.read(feedbackProvider).emit(GeoFeedback.tap);
    setState(() => _started = true);
    await ref.read(practiceProvider.notifier).start(module: module);
  }

  Future<void> _confirm(Exercise exercise) async {
    final bool correct = ref.read(practiceProvider.notifier).confirm();
    final FeedbackService feedback = ref.read(feedbackProvider);
    feedback.emit(correct ? GeoFeedback.correct : GeoFeedback.wrong);
    await ref.read(progressProvider.notifier).recordAttempt(
          itemId: exercise.id,
          competency: exercise.competency,
          correct: correct,
        );
  }

  void _next(PracticeState state) {
    final bool last = state.index + 1 >= state.total;
    final FeedbackService feedback = ref.read(feedbackProvider);
    feedback.emit(last ? GeoFeedback.complete : GeoFeedback.tap);
    ref.read(practiceProvider.notifier).next();
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
        body: GeoMessage(
          icon: Icons.error_outline,
          color: GeoPalette.hematite,
          title: 'No se pudieron cargar los ejercicios',
          message: '${state.error}',
        ),
      );
    }
    if (!state.hasExercises) {
      return Scaffold(
        appBar: AppBar(title: const Text('Práctica')),
        body: const GeoMessage(
          icon: Icons.inbox_outlined,
          title: 'Sin ejercicios',
          message: 'No hay ejercicios disponibles para este módulo.',
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
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: state.completion),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: GeoSpacing.gutter),
            child: Center(
              child: GeoTag(
                label: _difficultyLabel(exercise.difficulty),
                color: _difficultyColor(exercise.difficulty),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: geoScreenPadding(context, top: 12, bottom: 32),
        children: <Widget>[
          GeoCard(
            accentColor: GeoPalette.slate,
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    exercise.context,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(exercise.stem, style: theme.textTheme.titleMedium),
          const SizedBox(height: 18),
          ...exercise.options.map(
            (ExerciseOption option) => AnswerOptionTile(
              option: option,
              selected: state.selectedOptionId == option.id,
              revealed: state.answered,
              onTap: () {
                ref.read(feedbackProvider).emit(GeoFeedback.select);
                ref.read(practiceProvider.notifier).select(option.id);
              },
            ),
          ),
          const SizedBox(height: 8),
          if (state.answered) ...<Widget>[
            ExplanationPanel(
              correct: exercise.isCorrect(state.selectedOptionId ?? ''),
              explanation: exercise.explanation,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => _next(state),
              child: Text(
                state.index + 1 >= state.total ? 'Ver resultado' : 'Siguiente',
              ),
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

  static String _difficultyLabel(int difficulty) {
    if (difficulty <= 1) {
      return 'Reconocimiento';
    }
    if (difficulty == 2) {
      return 'Aplicación';
    }
    return 'Decisión';
  }

  static Color _difficultyColor(int difficulty) {
    if (difficulty <= 1) {
      return GeoPalette.malachite;
    }
    if (difficulty == 2) {
      return GeoPalette.pyrite;
    }
    return GeoPalette.hematite;
  }
}

/// Seleccion del modulo de practica.
class _ModulePicker extends ConsumerWidget {
  const _ModulePicker({required this.onPick});

  final void Function(ExerciseModule?) onPick;

  static const Map<ExerciseModule, String> _descriptions =
      <ExerciseModule, String>{
    ExerciseModule.identificacion:
        'Propiedades determinativas, raya, dureza y confusiones clásicas',
    ExerciseModule.clasificacion:
        'Origen, textura y lectura minera de la roca huésped',
    ExerciseModule.estructuras:
        'Vetas, fallas y pliegues: qué hacer cuando la estructura corta',
  };

  static const Map<ExerciseModule, IconData> _icons =
      <ExerciseModule, IconData>{
    ExerciseModule.identificacion: Icons.diamond_outlined,
    ExerciseModule.clasificacion: Icons.landscape_outlined,
    ExerciseModule.estructuras: Icons.architecture,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final List<Exercise> exercises =
        ref.watch(exercisesProvider).value ?? <Exercise>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Práctica')),
      body: ListView(
        padding: geoScreenPadding(context, top: 8, bottom: 32),
        children: <Widget>[
          Text(
            'Sesiones de ocho ejercicios. Los que fallaste antes vuelven a '
            'aparecer primero, y cada respuesta muestra el razonamiento '
            'completo, se acierte o no.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          _MixedSessionCard(onTap: () => onPick(null)),
          const SizedBox(height: 24),
          const GeoSectionHeader(
            title: 'Por módulo',
            subtitle: 'Cuando quieres insistir en una sola competencia',
          ),
          for (final ExerciseModule module in ExerciseModule.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GeoCard(
                onTap: () => onPick(module),
                child: Row(
                  children: <Widget>[
                    GeoIconBadge(
                      icon: _icons[module] ?? Icons.school_outlined,
                      color: GeoPalette.malachite,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            module.label,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _descriptions[module] ?? '',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          GeoTag(
                            label: '${_countFor(exercises, module)} ejercicios',
                            icon: Icons.list_alt,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          GeoCard(
            accentColor: GeoPalette.azurite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Cómo se evalúa', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(
                  'Cada ejercicio se clasifica en tres niveles: '
                  'reconocimiento (identificar), aplicación (usar el criterio '
                  'en un caso) y decisión (elegir entre alternativas con '
                  'consecuencias). Una competencia se considera consolidada '
                  'con al menos cinco intentos y 80 % de acierto, y los '
                  'errores vuelven a la cola hasta que se aciertan.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static int _countFor(List<Exercise> exercises, ExerciseModule module) {
    return exercises
        .where((Exercise exercise) => exercise.module == module)
        .length;
  }
}

/// Tarjeta destacada de la sesion mixta.
class _MixedSessionCard extends StatelessWidget {
  const _MixedSessionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(GeoSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GeoSpacing.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: GeoGradients.accent,
            borderRadius: BorderRadius.circular(GeoSpacing.cardRadius),
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.shuffle,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Sesión mixta',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Minerales, rocas y estructuras combinados',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
            ],
          ),
        ),
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
    final Color accent = ratio >= 0.8
        ? GeoPalette.malachite
        : (ratio >= 0.5 ? GeoPalette.pyrite : GeoPalette.hematite);
    final String message = ratio >= 0.8
        ? 'Criterio consolidado en esta selección de ejercicios.'
        : (ratio >= 0.5
            ? 'Base correcta, con confusiones puntuales todavía activas.'
            : 'Conviene repasar las fichas antes de la siguiente sesión: los '
                'errores se concentran en propiedades diagnósticas.');

    return Scaffold(
      appBar: AppBar(title: const Text('Sesión completada')),
      body: ListView(
        padding: geoScreenPadding(context, top: 12, bottom: 32),
        children: <Widget>[
          GeoCard(
            accentColor: accent,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 62,
                            height: 62,
                            child: CircularProgressIndicator(
                              value: ratio,
                              strokeWidth: 7,
                              valueColor: AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ),
                          Text(
                            '${(ratio * 100).round()}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '$correct de $total',
                            style: theme.textTheme.headlineSmall,
                          ),
                          Text(
                            'respuestas correctas',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(message, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onRestart,
            child: const Text('Nueva sesión'),
          ),
        ],
      ),
    );
  }
}
