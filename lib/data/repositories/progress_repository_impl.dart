import '../../domain/entities/attempt.dart';
import '../../domain/entities/student_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';

/// Persiste el avance serializandolo completo en cada escritura.
///
/// Es aceptable porque el objeto es pequeño; si el volumen creciera (por
/// ejemplo al sincronizar con un backend institucional) correspondería pasar a
/// escritura incremental sobre una base local.
class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._dataSource);

  final ProgressLocalDataSource _dataSource;

  StudentProgress? _cached;

  @override
  Future<StudentProgress> load() async {
    if (_cached != null) {
      return _cached!;
    }
    final Map<String, dynamic>? raw = await _dataSource.read();
    if (raw == null) {
      return _cached = const StudentProgress.empty();
    }
    return _cached = _fromJson(raw);
  }

  @override
  Future<StudentProgress> recordAttempt(Attempt attempt) async {
    final StudentProgress current = await load();
    final StudentProgress updated = current.copyWith(
      attempts: <Attempt>[...current.attempts, attempt],
    );
    return _persist(updated);
  }

  @override
  Future<StudentProgress> markMineralReviewed(String mineralId) async {
    final StudentProgress current = await load();
    if (current.reviewedMineralIds.contains(mineralId)) {
      return current;
    }
    final StudentProgress updated = current.copyWith(
      reviewedMineralIds: <String>{...current.reviewedMineralIds, mineralId},
    );
    return _persist(updated);
  }

  @override
  Future<StudentProgress> markCaseCompleted(String caseId) async {
    final StudentProgress current = await load();
    if (current.completedCaseIds.contains(caseId)) {
      return current;
    }
    final StudentProgress updated = current.copyWith(
      completedCaseIds: <String>{...current.completedCaseIds, caseId},
    );
    return _persist(updated);
  }

  @override
  Future<StudentProgress> reset() async {
    await _dataSource.clear();
    return _cached = const StudentProgress.empty();
  }

  Future<StudentProgress> _persist(StudentProgress progress) async {
    await _dataSource.write(_toJson(progress));
    return _cached = progress;
  }

  static Map<String, dynamic> _toJson(StudentProgress progress) {
    return <String, dynamic>{
      'attempts': progress.attempts
          .map((Attempt attempt) => attempt.toJson())
          .toList(),
      'reviewedMineralIds': progress.reviewedMineralIds.toList(),
      'completedCaseIds': progress.completedCaseIds.toList(),
    };
  }

  static StudentProgress _fromJson(Map<String, dynamic> json) {
    return StudentProgress(
      attempts: ((json['attempts'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) =>
              Attempt.fromJson(item as Map<String, dynamic>))
          .toList(),
      reviewedMineralIds:
          ((json['reviewedMineralIds'] as List<dynamic>?) ?? <dynamic>[])
              .map((dynamic item) => item as String)
              .toSet(),
      completedCaseIds:
          ((json['completedCaseIds'] as List<dynamic>?) ?? <dynamic>[])
              .map((dynamic item) => item as String)
              .toSet(),
    );
  }
}
