import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/mineral.dart';
import '../../domain/entities/student_progress.dart';
import '../providers.dart';
import '../widgets/geo_card.dart';

/// Panel de avance.
///
/// Reporta evidencia de aprendizaje (aciertos por competencia, confusiones sin
/// resolver) y no metricas de uso como tiempo en pantalla, que no dicen nada
/// sobre si el estudiante aprendio.
class ProgressView extends ConsumerWidget {
  const ProgressView({super.key});

  static const Map<String, String> _competencyLabels = <String, String>{
    'identificacion_minerales': 'Identificación de minerales',
    'clasificacion_rocas': 'Clasificación de rocas',
    'interpretacion_estructuras': 'Interpretación estructural',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<StudentProgress> progressAsync =
        ref.watch(progressProvider);
    final int catalogSize =
        (ref.watch(mineralsProvider).value ?? <Mineral>[]).length;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi avance'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reiniciar avance',
            icon: const Icon(Icons.restart_alt, size: 20),
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudo cargar el avance.\n$error'),
          ),
        ),
        data: (StudentProgress progress) {
          if (progress.totalAttempts == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Todavía no hay datos.\nResuelve una sesión de práctica o un '
                  'caso para empezar a medir tu criterio.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            );
          }

          final List<CompetencyScore> scores = progress.competencyScores;
          final Set<String> pending = progress.pendingReviewItemIds;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: <Widget>[
              GeoCard(
                accentColor: GeoPalette.malachite,
                child: Row(
                  children: <Widget>[
                    _Metric(
                      value: '${progress.totalCorrect}/'
                          '${progress.totalAttempts}',
                      label: 'Respuestas correctas',
                    ),
                    _Metric(
                      value: '${(progress.globalAccuracy * 100).round()} %',
                      label: 'Acierto global',
                    ),
                    _Metric(
                      value: catalogSize == 0
                          ? '${progress.reviewedMineralIds.length}'
                          : '${progress.reviewedMineralIds.length}/'
                              '$catalogSize',
                      label: 'Fichas revisadas',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Por competencia', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Se considera consolidada con al menos 5 intentos y 80 % de '
                'acierto.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ...scores.map(
                (CompetencyScore score) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CompetencyRow(
                    label: _competencyLabels[score.competency] ??
                        score.competency,
                    score: score,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GeoCard(
                accentColor: pending.isEmpty
                    ? GeoPalette.malachite
                    : GeoPalette.hematite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Confusiones sin resolver',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      pending.isEmpty
                          ? 'No quedan ejercicios fallados pendientes de '
                              'recuperar.'
                          : '${pending.length} ejercicio(s) fallados aún sin '
                              'acertar. Vuelven a aparecer al inicio de la '
                              'próxima sesión de práctica.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GeoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Casos resueltos',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('${progress.completedCaseIds.length}',
                        style: theme.textTheme.headlineSmall),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Reiniciar avance'),
        content: const Text(
          'Se borrarán todos los intentos registrados en este dispositivo. '
          'Esta acción no se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(progressProvider.notifier).reset();
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: theme.textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _CompetencyRow extends StatelessWidget {
  const _CompetencyRow({required this.label, required this.score});

  final String label;
  final CompetencyScore score;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent =
        score.isMastered ? GeoPalette.malachite : GeoPalette.pyrite;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
            Text(
              '${score.correct}/${score.attempts}',
              style: theme.textTheme.bodySmall,
            ),
            if (score.isMastered) ...<Widget>[
              const SizedBox(width: 8),
              const Icon(Icons.verified_outlined,
                  size: 16, color: GeoPalette.malachite),
            ],
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score.accuracy,
            minHeight: 6,
            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.35),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }
}
