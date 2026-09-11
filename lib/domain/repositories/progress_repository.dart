import '../entities/attempt.dart';
import '../entities/student_progress.dart';

/// Contrato de persistencia del avance del estudiante.
abstract class ProgressRepository {
  Future<StudentProgress> load();

  Future<StudentProgress> recordAttempt(Attempt attempt);

  Future<StudentProgress> markMineralReviewed(String mineralId);

  Future<StudentProgress> markCaseCompleted(String caseId);

  Future<StudentProgress> reset();
}
