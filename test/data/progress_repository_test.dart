import 'package:flutter_test/flutter_test.dart';
import 'package:geomine_explorer/data/datasources/progress_local_datasource.dart';
import 'package:geomine_explorer/data/repositories/progress_repository_impl.dart';
import 'package:geomine_explorer/domain/entities/attempt.dart';
import 'package:geomine_explorer/domain/entities/student_progress.dart';

void main() {
  late InMemoryProgressLocalDataSource dataSource;
  late ProgressRepositoryImpl repository;

  setUp(() {
    dataSource = InMemoryProgressLocalDataSource();
    repository = ProgressRepositoryImpl(dataSource);
  });

  Attempt attempt(String id, bool correct) => Attempt(
        itemId: id,
        competency: 'identificacion_minerales',
        correct: correct,
        timestamp: DateTime(2026, 3, 4, 10, 30),
        source: AttemptSource.exercise,
      );

  test('el primer arranque devuelve progreso vacío', () async {
    final StudentProgress progress = await repository.load();
    expect(progress.totalAttempts, 0);
  });

  test('un intento se acumula y se devuelve el estado actualizado', () async {
    final StudentProgress progress =
        await repository.recordAttempt(attempt('ex_1', true));
    expect(progress.totalAttempts, 1);
    expect(progress.totalCorrect, 1);
  });

  test('el avance sobrevive a una instancia nueva del repositorio', () async {
    await repository.recordAttempt(attempt('ex_1', false));
    await repository.markMineralReviewed('galena');
    await repository.markCaseCompleted('caso_veta_perdida');

    final ProgressRepositoryImpl reopened = ProgressRepositoryImpl(dataSource);
    final StudentProgress restored = await reopened.load();

    expect(restored.totalAttempts, 1);
    expect(restored.attempts.single.itemId, 'ex_1');
    expect(restored.attempts.single.correct, isFalse);
    expect(restored.attempts.single.timestamp, DateTime(2026, 3, 4, 10, 30));
    expect(restored.reviewedMineralIds, contains('galena'));
    expect(restored.completedCaseIds, contains('caso_veta_perdida'));
    expect(restored.pendingReviewItemIds, <String>{'ex_1'});
  });

  test('marcar dos veces la misma ficha no duplica ni reescribe', () async {
    await repository.markMineralReviewed('pirita');
    final StudentProgress second =
        await repository.markMineralReviewed('pirita');
    expect(second.reviewedMineralIds.length, 1);
  });

  test('reset deja el almacenamiento limpio', () async {
    await repository.recordAttempt(attempt('ex_1', true));
    await repository.reset();

    expect(await dataSource.read(), isNull);
    final StudentProgress restored =
        await ProgressRepositoryImpl(dataSource).load();
    expect(restored.totalAttempts, 0);
  });
}
