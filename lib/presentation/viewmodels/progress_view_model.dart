import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/attempt.dart';
import '../../domain/entities/student_progress.dart';
import '../../domain/repositories/progress_repository.dart';

/// ViewModel del avance del estudiante.
///
/// Es el unico punto desde el que se escribe progreso, de modo que practica,
/// casos y catalogo comparten una sola fuente de verdad.
class ProgressViewModel extends StateNotifier<AsyncValue<StudentProgress>> {
  ProgressViewModel(this._repository)
      : super(const AsyncValue<StudentProgress>.loading()) {
    load();
  }

  final ProgressRepository _repository;

  Future<void> load() async {
    state = const AsyncValue<StudentProgress>.loading();
    try {
      state = AsyncValue<StudentProgress>.data(await _repository.load());
    } catch (error, stackTrace) {
      state = AsyncValue<StudentProgress>.error(error, stackTrace);
    }
  }

  Future<void> recordAttempt({
    required String itemId,
    required String competency,
    required bool correct,
    AttemptSource source = AttemptSource.exercise,
  }) async {
    final Attempt attempt = Attempt(
      itemId: itemId,
      competency: competency,
      correct: correct,
      timestamp: DateTime.now(),
      source: source,
    );
    try {
      state = AsyncValue<StudentProgress>.data(
        await _repository.recordAttempt(attempt),
      );
    } catch (error, stackTrace) {
      state = AsyncValue<StudentProgress>.error(error, stackTrace);
    }
  }

  Future<void> markMineralReviewed(String mineralId) async {
    state = AsyncValue<StudentProgress>.data(
      await _repository.markMineralReviewed(mineralId),
    );
  }

  Future<void> markCaseCompleted(String caseId) async {
    state = AsyncValue<StudentProgress>.data(
      await _repository.markCaseCompleted(caseId),
    );
  }

  Future<void> reset() async {
    state = AsyncValue<StudentProgress>.data(await _repository.reset());
  }
}
