import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/mining_case.dart';
import '../../domain/entities/student_progress.dart';
import '../providers.dart';
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
        error: (Object error, StackTrace stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudieron cargar los casos.\n$error'),
          ),
        ),
        data: (List<MiningCase> items) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Text(
              'Escenarios encadenados donde cada decisión condiciona la '
              'siguiente, como ocurre en una campaña real.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            ...items.map(
              (MiningCase item) {
                final bool completed =
                    progress.completedCaseIds.contains(item.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GeoCard(
                    accentColor: completed
                        ? GeoPalette.malachite
                        : GeoPalette.pyrite,
                    onTap: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => CaseRunView(caseId: item.id),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(item.title,
                                  style: theme.textTheme.titleMedium),
                            ),
                            if (completed)
                              const Icon(Icons.check_circle,
                                  size: 18, color: GeoPalette.malachite),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(item.deposit, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: <Widget>[
                            GeoTag(label: '${item.stepCount} decisiones'),
                            GeoTag(label: 'Nivel ${item.difficulty}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
