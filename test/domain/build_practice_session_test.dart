import 'package:flutter_test/flutter_test.dart';
import 'package:geomine_explorer/domain/entities/attempt.dart';
import 'package:geomine_explorer/domain/entities/exercise.dart';
import 'package:geomine_explorer/domain/entities/student_progress.dart';
import 'package:geomine_explorer/domain/usecases/build_practice_session.dart';

import '../fixtures/test_data.dart';

StudentProgress progressWith(List<Attempt> attempts) => StudentProgress(
      attempts: attempts,
      reviewedMineralIds: const <String>{},
      completedCaseIds: const <String>{},
    );

Attempt attempt(String id, bool correct) => Attempt(
      itemId: id,
      competency: 'competencia_prueba',
      correct: correct,
      timestamp: DateTime(2026, 1, 1),
      source: AttemptSource.exercise,
    );

void main() {
  const BuildPracticeSession build = BuildPracticeSession();
  final List<Exercise> all = testExercises();

  test('sin historial ordena de menor a mayor dificultad', () {
    final List<Exercise> session = build(
      exercises: all,
      progress: const StudentProgress.empty(),
    );
    final List<int> difficulties =
        session.map((Exercise e) => e.difficulty).toList();
    final List<int> sorted = List<int>.from(difficulties)..sort();
    expect(difficulties, sorted);
  });

  test('los ejercicios fallados aparecen primero', () {
    final List<Exercise> session = build(
      exercises: all,
      progress: progressWith(<Attempt>[attempt('ex_b', false)]),
    );
    // ex_b es el más difícil del set; debe adelantarse por estar pendiente.
    expect(session.first.id, 'ex_b');
  });

  test('un fallo ya recuperado no se adelanta', () {
    final List<Exercise> session = build(
      exercises: all,
      progress: progressWith(<Attempt>[
        attempt('ex_b', false),
        attempt('ex_b', true),
      ]),
    );
    expect(session.first.id, isNot('ex_b'));
  });

  test('filtra por módulo cuando se solicita', () {
    final List<Exercise> session = build(
      exercises: all,
      progress: const StudentProgress.empty(),
      module: ExerciseModule.identificacion,
    );
    expect(session.length, 3);
    expect(
      session.every((Exercise e) => e.module == ExerciseModule.identificacion),
      isTrue,
    );
  });

  test('respeta el límite de la sesión', () {
    final List<Exercise> session = build(
      exercises: all,
      progress: const StudentProgress.empty(),
      limit: 2,
    );
    expect(session.length, 2);
  });

  test('el orden es determinista ante empates', () {
    final List<Exercise> first =
        build(exercises: all, progress: const StudentProgress.empty());
    final List<Exercise> second =
        build(exercises: all, progress: const StudentProgress.empty());
    expect(
      first.map((Exercise e) => e.id).toList(),
      second.map((Exercise e) => e.id).toList(),
    );
  });
}
