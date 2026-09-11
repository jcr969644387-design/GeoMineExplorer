import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/attempt.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/mining_case.dart';
import '../providers.dart';
import '../services/feedback_service.dart';
import '../viewmodels/case_view_model.dart';
import '../widgets/answer_option_tile.dart';
import '../widgets/geo_card.dart';

/// Resolucion paso a paso de un caso minero.
class CaseRunView extends ConsumerWidget {
  const CaseRunView({super.key, required this.caseId});

  final String caseId;

  Future<void> _confirm(
    WidgetRef ref,
    MiningCase miningCase,
    CaseStep step,
  ) async {
    final bool correct = ref.read(caseProvider(caseId).notifier).confirm();
    final FeedbackService feedback = ref.read(feedbackProvider);
    feedback.emit(correct ? GeoFeedback.correct : GeoFeedback.wrong);
    await ref.read(progressProvider.notifier).recordAttempt(
          itemId: '${miningCase.id}:${step.id}',
          competency: miningCase.competency,
          correct: correct,
          source: AttemptSource.caseStep,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CaseRunState state = ref.watch(caseProvider(caseId));
    final ThemeData theme = Theme.of(context);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final MiningCase? miningCase = state.miningCase;
    if (miningCase == null) {
      return Scaffold(
        appBar: AppBar(),
        body: GeoMessage(
          icon: Icons.error_outline,
          color: GeoPalette.hematite,
          title: 'No se pudo cargar el caso',
          message: '${state.error}',
        ),
      );
    }

    if (state.isFinished) {
      return _CaseSummary(
        miningCase: miningCase,
        correct: state.correctCount,
      );
    }

    final CaseStep step = state.currentStep!;

    return Scaffold(
      appBar: AppBar(
        title: Text(miningCase.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: state.stepIndex / miningCase.stepCount,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          GeoSpacing.gutter,
          12,
          GeoSpacing.gutter,
          32,
        ),
        children: <Widget>[
          if (state.stepIndex == 0) ...<Widget>[
            GeoCard(
              accentColor: GeoPalette.slate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const GeoIconBadge(
                        icon: Icons.assignment_outlined,
                        color: GeoPalette.slate,
                        size: 38,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Encargo',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    miningCase.briefing,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GeoTag(
                label: 'Etapa ${state.stepIndex + 1} de '
                    '${miningCase.stepCount}',
                color: GeoPalette.malachite,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(step.title, style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GeoCard(
            accentColor: GeoPalette.pyriteLight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.description_outlined, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step.narrative,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(step.question, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          ...step.options.map(
            (ExerciseOption option) => AnswerOptionTile(
              option: option,
              selected: state.selectedOptionId == option.id,
              revealed: state.answered,
              onTap: () {
                ref.read(feedbackProvider).emit(GeoFeedback.select);
                ref.read(caseProvider(caseId).notifier).select(option.id);
              },
            ),
          ),
          const SizedBox(height: 8),
          if (state.answered) ...<Widget>[
            ExplanationPanel(
              correct: step.isCorrect(state.selectedOptionId ?? ''),
              explanation: step.explanation,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () async {
                final bool isLast = state.stepIndex + 1 >= miningCase.stepCount;
                final FeedbackService feedback = ref.read(feedbackProvider);
                feedback.emit(isLast ? GeoFeedback.complete : GeoFeedback.tap);
                ref.read(caseProvider(caseId).notifier).next();
                if (isLast) {
                  await ref
                      .read(progressProvider.notifier)
                      .markCaseCompleted(miningCase.id);
                }
              },
              child: Text(
                state.stepIndex + 1 >= miningCase.stepCount
                    ? 'Cerrar el caso'
                    : 'Siguiente etapa',
              ),
            ),
          ] else
            FilledButton(
              onPressed: state.selectedOptionId == null
                  ? null
                  : () => _confirm(ref, miningCase, step),
              child: const Text('Tomar la decisión'),
            ),
        ],
      ),
    );
  }
}

class _CaseSummary extends StatelessWidget {
  const _CaseSummary({required this.miningCase, required this.correct});

  final MiningCase miningCase;
  final int correct;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(miningCase.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          GeoSpacing.gutter,
          12,
          GeoSpacing.gutter,
          32,
        ),
        children: <Widget>[
          GeoCard(
            accentColor: GeoPalette.malachite,
            padding: const EdgeInsets.all(22),
            child: Row(
              children: <Widget>[
                const GeoIconBadge(
                  icon: Icons.verified_outlined,
                  color: GeoPalette.malachite,
                  size: 48,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$correct de ${miningCase.stepCount}',
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        'decisiones correctas',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GeoCard(
            accentColor: GeoPalette.pyrite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Idea central del caso',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(miningCase.closing, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver a los casos'),
          ),
        ],
      ),
    );
  }
}
