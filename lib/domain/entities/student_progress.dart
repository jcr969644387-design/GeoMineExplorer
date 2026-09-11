import 'attempt.dart';

/// Desempeño acumulado en una competencia.
class CompetencyScore {
  const CompetencyScore({
    required this.competency,
    required this.attempts,
    required this.correct,
  });

  final String competency;
  final int attempts;
  final int correct;

  double get accuracy => attempts == 0 ? 0 : correct / attempts;

  /// Se considera una competencia consolidada con al menos 5 intentos y 80 %
  /// de acierto. El umbral doble evita declarar dominio con un solo acierto.
  bool get isMastered => attempts >= 5 && accuracy >= 0.8;
}

/// Estado de aprendizaje del estudiante, derivado de sus intentos.
class StudentProgress {
  const StudentProgress({
    required this.attempts,
    required this.reviewedMineralIds,
    required this.completedCaseIds,
  });

  const StudentProgress.empty()
      : attempts = const <Attempt>[],
        reviewedMineralIds = const <String>{},
        completedCaseIds = const <String>{};

  final List<Attempt> attempts;

  /// Minerales cuya ficha completa fue abierta al menos una vez.
  final Set<String> reviewedMineralIds;
  final Set<String> completedCaseIds;

  int get totalAttempts => attempts.length;

  int get totalCorrect =>
      attempts.where((Attempt attempt) => attempt.correct).length;

  double get globalAccuracy =>
      totalAttempts == 0 ? 0 : totalCorrect / totalAttempts;

  /// Agrupa los intentos por competencia para el panel de progreso.
  List<CompetencyScore> get competencyScores {
    final Map<String, List<Attempt>> grouped = <String, List<Attempt>>{};
    for (final Attempt attempt in attempts) {
      grouped.putIfAbsent(attempt.competency, () => <Attempt>[]).add(attempt);
    }
    final List<CompetencyScore> scores = grouped.entries
        .map((MapEntry<String, List<Attempt>> entry) => CompetencyScore(
              competency: entry.key,
              attempts: entry.value.length,
              correct: entry.value
                  .where((Attempt attempt) => attempt.correct)
                  .length,
            ))
        .toList();
    scores.sort((CompetencyScore a, CompetencyScore b) =>
        a.competency.compareTo(b.competency));
    return scores;
  }

  /// Items fallados al menos una vez y no acertados despues.
  /// Es la base de la cola de repaso dirigido.
  Set<String> get pendingReviewItemIds {
    final Set<String> failed = <String>{};
    final Set<String> laterCorrect = <String>{};
    final List<Attempt> ordered = List<Attempt>.from(attempts)
      ..sort((Attempt a, Attempt b) => a.timestamp.compareTo(b.timestamp));
    for (final Attempt attempt in ordered) {
      if (attempt.correct) {
        laterCorrect.add(attempt.itemId);
      } else {
        failed.add(attempt.itemId);
        laterCorrect.remove(attempt.itemId);
      }
    }
    return failed.difference(laterCorrect);
  }

  StudentProgress copyWith({
    List<Attempt>? attempts,
    Set<String>? reviewedMineralIds,
    Set<String>? completedCaseIds,
  }) {
    return StudentProgress(
      attempts: attempts ?? this.attempts,
      reviewedMineralIds: reviewedMineralIds ?? this.reviewedMineralIds,
      completedCaseIds: completedCaseIds ?? this.completedCaseIds,
    );
  }
}
