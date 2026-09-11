import '../entities/attempt.dart';
import '../entities/exercise.dart';
import '../entities/student_progress.dart';

/// Arma la secuencia de ejercicios de una sesion de practica.
///
/// Orden de prioridad:
/// 1. Ejercicios fallados y aun no recuperados (repaso dirigido).
/// 2. Ejercicios nunca intentados, de menor a mayor dificultad.
/// 3. Ejercicios ya acertados, para consolidar.
///
/// El repaso dirigido va primero porque el problema educativo declarado es la
/// confusion persistente entre minerales parecidos: reintentar justamente lo
/// que se fallo es lo que corrige esa confusion.
class BuildPracticeSession {
  const BuildPracticeSession();

  List<Exercise> call({
    required List<Exercise> exercises,
    required StudentProgress progress,
    ExerciseModule? module,
    int limit = 8,
  }) {
    final List<Exercise> pool = module == null
        ? List<Exercise>.from(exercises)
        : exercises
            .where((Exercise exercise) => exercise.module == module)
            .toList();

    final Set<String> pendingReview = progress.pendingReviewItemIds;
    final Set<String> attempted =
        progress.attempts.map((Attempt attempt) => attempt.itemId).toSet();

    int rank(Exercise exercise) {
      if (pendingReview.contains(exercise.id)) {
        return 0;
      }
      if (!attempted.contains(exercise.id)) {
        return 1;
      }
      return 2;
    }

    pool.sort((Exercise a, Exercise b) {
      final int rankComparison = rank(a).compareTo(rank(b));
      if (rankComparison != 0) {
        return rankComparison;
      }
      final int difficultyComparison = a.difficulty.compareTo(b.difficulty);
      if (difficultyComparison != 0) {
        return difficultyComparison;
      }
      return a.id.compareTo(b.id);
    });

    return pool.take(limit).toList();
  }
}
