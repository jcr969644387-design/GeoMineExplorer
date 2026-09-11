import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/student_progress.dart';
import '../../domain/repositories/geology_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/usecases/build_practice_session.dart';

/// Estado de una sesion de practica.
class PracticeState {
  const PracticeState({
    this.isLoading = false,
    this.exercises = const <Exercise>[],
    this.index = 0,
    this.selectedOptionId,
    this.answered = false,
    this.correctCount = 0,
    this.module,
    this.error,
  });

  final bool isLoading;
  final List<Exercise> exercises;
  final int index;
  final String? selectedOptionId;

  /// Si ya se confirmo la respuesta de la pregunta actual.
  final bool answered;
  final int correctCount;
  final ExerciseModule? module;
  final Object? error;

  bool get hasExercises => exercises.isNotEmpty;

  bool get isFinished => hasExercises && index >= exercises.length;

  Exercise? get current =>
      hasExercises && index < exercises.length ? exercises[index] : null;

  int get total => exercises.length;

  /// Progreso 0..1 de la sesion, para la barra superior.
  double get completion => total == 0 ? 0 : index / total;

  PracticeState copyWith({
    bool? isLoading,
    List<Exercise>? exercises,
    int? index,
    String? selectedOptionId,
    bool? answered,
    int? correctCount,
    ExerciseModule? module,
    Object? error,
    bool clearSelection = false,
    bool clearModule = false,
    bool clearError = false,
  }) {
    return PracticeState(
      isLoading: isLoading ?? this.isLoading,
      exercises: exercises ?? this.exercises,
      index: index ?? this.index,
      selectedOptionId:
          clearSelection ? null : (selectedOptionId ?? this.selectedOptionId),
      answered: answered ?? this.answered,
      correctCount: correctCount ?? this.correctCount,
      module: clearModule ? null : (module ?? this.module),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// ViewModel de la sesion de practica.
class PracticeViewModel extends StateNotifier<PracticeState> {
  PracticeViewModel({
    required GeologyRepository repository,
    required ProgressRepository progressRepository,
    BuildPracticeSession buildSession = const BuildPracticeSession(),
  })  : _repository = repository,
        _progressRepository = progressRepository,
        _buildSession = buildSession,
        super(const PracticeState());

  final GeologyRepository _repository;
  final ProgressRepository _progressRepository;
  final BuildPracticeSession _buildSession;

  /// Numero de ejercicios por sesion.
  ///
  /// Ocho es deliberado: una sesion corta que un estudiante completa entre
  /// clases, en lugar de un cuestionario largo que se abandona a la mitad.
  static const int sessionLength = 8;

  Future<void> start({ExerciseModule? module}) async {
    state = PracticeState(isLoading: true, module: module);
    try {
      final List<Exercise> all = await _repository.getExercises();
      final StudentProgress progress = await _progressRepository.load();
      final List<Exercise> session = _buildSession(
        exercises: all,
        progress: progress,
        module: module,
        limit: sessionLength,
      );
      state = PracticeState(exercises: session, module: module);
    } catch (error) {
      state = PracticeState(module: module, error: error);
    }
  }

  void select(String optionId) {
    if (state.answered) {
      return;
    }
    state = state.copyWith(selectedOptionId: optionId);
  }

  /// Confirma la respuesta actual. Devuelve true si fue correcta.
  bool confirm() {
    final Exercise? exercise = state.current;
    final String? selected = state.selectedOptionId;
    if (exercise == null || selected == null || state.answered) {
      return false;
    }
    final bool correct = exercise.isCorrect(selected);
    state = state.copyWith(
      answered: true,
      correctCount: state.correctCount + (correct ? 1 : 0),
    );
    return correct;
  }

  void next() {
    if (!state.answered) {
      return;
    }
    state = state.copyWith(
      index: state.index + 1,
      answered: false,
      clearSelection: true,
    );
  }
}
