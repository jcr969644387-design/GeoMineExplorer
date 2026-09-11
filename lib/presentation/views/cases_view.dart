import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/mining_case.dart';
import '../../domain/entities/student_progress.dart';
import '../providers.dart';
import '../services/feedback_service.dart';
import '../widgets/geo_card.dart';
import 'case_run_view.dart';

/// Listado de casos mineros.
class CasesView extends ConsumerWidget {
  const CasesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MiningCase>> cases = ref.watch(casesProvider);
    final StudentProgress progress =
        ref.watch(progressProvider).value ?? const StudentProgress.empty();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Casos mineros')),
      body: cases.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => GeoMessage(
          icon: Icons.error_outline,
          color: GeoPalette.hematite,
          title: 'No se pudieron cargar los casos',
          message: '$error',
        ),
        data: (List<MiningCase> items) => ListView(
          padding: geoScreenPadding(context, top: 8, bottom: 32),
          children: <Widget>[
            Text(
              'Escenarios encadenados donde cada decisión condiciona la '
              'siguiente, como ocurre en una campaña real. No hay atajo: para '
              'cerrar el caso hay que atravesar todas las etapas.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            for (final MiningCase item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CaseCard(
                  item: item,
                  completed: progress.completedCaseIds.contains(item.id),
                ),
              ),
            const SizedBox(height: 6),
            GeoCard(
              accentColor: GeoPalette.azurite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Cómo se resuelve un caso',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cada etapa entrega información de campo parcial —un '
                    'mapeo, un resultado de laboratorio, un reporte de '
                    'sondaje— y exige una decisión antes de ver la siguiente. '
                    'La explicación aparece siempre, se acierte o no, porque '
                    'el criterio se construye entendiendo por qué una '
                    'alternativa era mejor, no solo cuál era.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseCard extends ConsumerWidget {
  const _CaseCard({required this.item, required this.completed});

  final MiningCase item;
  final bool completed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final Color accent =
        completed ? GeoPalette.malachite : GeoPalette.pyriteLight;

    return GeoCard(
      accentColor: accent,
      onTap: () {
        ref.read(feedbackProvider).emit(GeoFeedback.tap);
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => CaseRunView(caseId: item.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GeoIconBadge(
                icon: completed ? Icons.task_alt : Icons.engineering_outlined,
                color: completed ? GeoPalette.malachite : GeoPalette.pyrite,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(item.deposit, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              GeoTag(
                label: '${item.stepCount} decisiones',
                icon: Icons.alt_route,
              ),
              GeoTag(
                label: 'Nivel ${item.difficulty}',
                color: GeoPalette.slate,
              ),
              if (completed)
                const GeoTag(
                  label: 'Resuelto',
                  color: GeoPalette.malachite,
                  icon: Icons.check,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
