import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/mineral.dart';
import '../../domain/entities/student_progress.dart';
import '../providers.dart';
import '../services/feedback_service.dart';
import '../widgets/geo_card.dart';
import 'settings_view.dart';

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
            tooltip: 'Ajustes',
            icon: const Icon(Icons.tune, size: 22),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const SettingsView(),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Reiniciar avance',
            icon: const Icon(Icons.restart_alt, size: 22),
            onPressed: () => _confirmReset(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => GeoMessage(
          icon: Icons.error_outline,
          color: GeoPalette.hematite,
          title: 'No se pudo cargar el avance',
          message: '$error',
        ),
        data: (StudentProgress progress) {
          if (progress.totalAttempts == 0) {
            return const GeoMessage(
              icon: Icons.insights_outlined,
              title: 'Todavía no hay datos',
              message: 'Resuelve una sesión de práctica o un caso para '
                  'empezar a medir tu criterio. Aquí se registra qué has '
                  'acertado, no cuánto tiempo has pasado en la aplicación.',
            );
          }

          final List<CompetencyScore> scores = progress.competencyScores;
          final Set<String> pending = progress.pendingReviewItemIds;

          return ListView(
            padding: geoScreenPadding(context, top: 8, bottom: 32),
            children: <Widget>[
              GeoCard(
                accentColor: GeoPalette.malachite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: <Widget>[
                    _Metric(
                      value: '${(progress.globalAccuracy * 100).round()} %',
                      label: 'Acierto global',
                      color: GeoPalette.malachite,
                    ),
                    _Metric(
                      value: '${progress.totalCorrect}/'
                          '${progress.totalAttempts}',
                      label: 'Respuestas correctas',
                      color: GeoPalette.azurite,
                    ),
                    _Metric(
                      value: catalogSize == 0
                          ? '${progress.reviewedMineralIds.length}'
                          : '${progress.reviewedMineralIds.length}/'
                              '$catalogSize',
                      label: 'Fichas revisadas',
                      color: GeoPalette.pyrite,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const GeoSectionHeader(
                title: 'Por competencia',
                subtitle: 'Consolidada con al menos 5 intentos y 80 % de '
                    'acierto',
              ),
              for (final CompetencyScore score in scores)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _CompetencyRow(
                    label: _competencyLabels[score.competency] ??
                        score.competency,
                    score: score,
                  ),
                ),
              const SizedBox(height: 10),
              GeoCard(
                accentColor: pending.isEmpty
                    ? GeoPalette.malachite
                    : GeoPalette.hematite,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GeoIconBadge(
                      icon: pending.isEmpty
                          ? Icons.check_circle_outline
                          : Icons.refresh,
                      color: pending.isEmpty
                          ? GeoPalette.malachite
                          : GeoPalette.hematite,
                      size: 40,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Confusiones sin resolver',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pending.isEmpty
                                ? 'No quedan ejercicios fallados pendientes '
                                    'de recuperar.'
                                : '${pending.length} ejercicio(s) fallados '
                                    'aún sin acertar. Vuelven a aparecer al '
                                    'inicio de la próxima sesión de práctica.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GeoCard(
                child: Row(
                  children: <Widget>[
                    const GeoIconBadge(
                      icon: Icons.engineering_outlined,
                      color: GeoPalette.azurite,
                      size: 40,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Casos resueltos',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${progress.completedCaseIds.length}',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const GeoSectionHeader(title: 'Cómo leer este panel'),
              GeoCard(
                accentColor: GeoPalette.slate,
                child: Text(
                  'El acierto global mezcla competencias y por sí solo dice '
                  'poco: lo que importa es la barra más corta. Una '
                  'competencia con menos de cinco intentos todavía no es '
                  'medible, aunque muestre 100 %. Los ejercicios fallados se '
                  'reinyectan al inicio de la siguiente sesión hasta que se '
                  'aciertan, de modo que la cola pendiente tiende a cero solo '
                  'cuando el criterio se corrigió de verdad.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    ref.read(feedbackProvider).emit(GeoFeedback.tap);
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
  const _Metric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 3),
          Text(label, style: theme.textTheme.labelSmall),
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
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge),
            ),
            Text(
              '${score.correct}/${score.attempts}',
              style: theme.textTheme.bodySmall,
            ),
            if (score.isMastered) ...<Widget>[
              const SizedBox(width: 8),
              const Icon(
                Icons.verified_outlined,
                size: 16,
                color: GeoPalette.malachite,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: score.accuracy,
            minHeight: 8,
            backgroundColor: accent.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }
}
