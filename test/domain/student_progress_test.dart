import 'package:flutter_test/flutter_test.dart';
import 'package:geomine_explorer/domain/entities/attempt.dart';
import 'package:geomine_explorer/domain/entities/student_progress.dart';

Attempt attempt(String id, bool correct, int minute,
    {String competency = 'identificacion_minerales'}) {
  return Attempt(
    itemId: id,
    competency: competency,
    correct: correct,
    timestamp: DateTime(2026, 1, 1, 8, minute),
    source: AttemptSource.exercise,
  );
}

void main() {
  group('StudentProgress', () {
    test('el progreso vacío no divide por cero', () {
      const StudentProgress progress = StudentProgress.empty();
      expect(progress.globalAccuracy, 0);
      expect(progress.totalAttempts, 0);
      expect(progress.competencyScores, isEmpty);
    });

    test('calcula el acierto global', () {
      final StudentProgress progress = StudentProgress(
        attempts: <Attempt>[
          attempt('a', true, 1),
          attempt('b', false, 2),
          attempt('c', true, 3),
          attempt('d', true, 4),
        ],
        reviewedMineralIds: const <String>{},
        completedCaseIds: const <String>{},
      );
      expect(progress.totalCorrect, 3);
      expect(progress.globalAccuracy, closeTo(0.75, 0.001));
    });

    test('agrupa el desempeño por competencia', () {
      final StudentProgress progress = StudentProgress(
        attempts: <Attempt>[
          attempt('a', true, 1),
          attempt('b', false, 2),
          attempt('c', true, 3, competency: 'clasificacion_rocas'),
        ],
        reviewedMineralIds: const <String>{},
        completedCaseIds: const <String>{},
      );
      final List<CompetencyScore> scores = progress.competencyScores;
      expect(scores.length, 2);
      expect(scores.first.competency, 'clasificacion_rocas');
      expect(scores.first.accuracy, 1.0);
    });

    test('no declara dominio con pocos intentos aunque el acierto sea total',
        () {
      const CompetencyScore score = CompetencyScore(
        competency: 'identificacion_minerales',
        attempts: 2,
        correct: 2,
      );
      expect(score.accuracy, 1.0);
      expect(score.isMastered, isFalse);
    });

    test('declara dominio con al menos 5 intentos y 80 % de acierto', () {
      const CompetencyScore score = CompetencyScore(
        competency: 'identificacion_minerales',
        attempts: 5,
        correct: 4,
      );
      expect(score.isMastered, isTrue);
    });

    group('cola de repaso', () {
      test('un fallo deja el ejercicio pendiente', () {
        final StudentProgress progress = StudentProgress(
          attempts: <Attempt>[attempt('ex_1', false, 1)],
          reviewedMineralIds: const <String>{},
          completedCaseIds: const <String>{},
        );
        expect(progress.pendingReviewItemIds, <String>{'ex_1'});
      });

      test('acertarlo después lo saca de la cola', () {
        final StudentProgress progress = StudentProgress(
          attempts: <Attempt>[
            attempt('ex_1', false, 1),
            attempt('ex_1', true, 5),
          ],
          reviewedMineralIds: const <String>{},
          completedCaseIds: const <String>{},
        );
        expect(progress.pendingReviewItemIds, isEmpty);
      });

      test('volver a fallarlo lo reincorpora, sin importar el orden de carga',
          () {
        final StudentProgress progress = StudentProgress(
          attempts: <Attempt>[
            attempt('ex_1', false, 9), // llega desordenado a propósito
            attempt('ex_1', true, 5),
            attempt('ex_1', false, 1),
          ],
          reviewedMineralIds: const <String>{},
          completedCaseIds: const <String>{},
        );
        expect(progress.pendingReviewItemIds, <String>{'ex_1'});
      });
    });
  });
}
