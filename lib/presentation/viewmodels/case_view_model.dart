import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/mining_case.dart';
import '../../domain/repositories/geology_repository.dart';

/// Estado de la resolucion de un caso minero.
class CaseRunState {
  const CaseRunState({
    this.isLoading = true,
    this.miningCase,
    this.stepIndex = 0,
    this.selectedOptionId,
    this.answered = false,
    this.correctCount = 0,
    this.error,
  });

  final bool isLoading;
  final MiningCase? miningCase;
  final int stepIndex;
  final String? selectedOptionId;
  final bool answered;
  final int correctCount;
  final Object? error;

  bool get isFinished =>
      miningCase != null && stepIndex >= miningCase!.stepCount;

  CaseStep? get currentStep {
    final MiningCase? data = miningCase;
    if (data == null || stepIndex >= data.stepCount) {
      return null;
    }
    return data.steps[stepIndex];
  }

  CaseRunState copyWith({
    bool? isLoading,
    MiningCase? miningCase,
    int? stepIndex,
    String? selectedOptionId,
    bool? answered,
    int? correctCount,
    Object? error,
    bool clearSelection = false,
  }) {
    return CaseRunState(
      isLoading: isLoading ?? this.isLoading,
      miningCase: miningCase ?? this.miningCase,
      stepIndex: stepIndex ?? this.stepIndex,
      selectedOptionId:
          clearSelection ? null : (selectedOptionId ?? this.selectedOptionId),
      answered: answered ?? this.answered,
      correctCount: correctCount ?? this.correctCount,
      error: error ?? this.error,
    );
  }
}

/// ViewModel de un caso minero encadenado.
class CaseViewModel extends StateNotifier<CaseRunState> {
  CaseViewModel({
    required GeologyRepository repository,
    required String caseId,
  })  : _repository = repository,
        _caseId = caseId,
        super(const CaseRunState()) {
    _load();
  }

  final GeologyRepository _repository;
  final String _caseId;

  Future<void> _load() async {
    try {
      final List<MiningCase> cases = await _repository.getCases();
      final MiningCase found =
          cases.firstWhere((MiningCase item) => item.id == _caseId);
      state = CaseRunState(isLoading: false, miningCase: found);
    } catch (error) {
      state = CaseRunState(isLoading: false, error: error);
    }
  }

  void select(String optionId) {
    if (state.answered) {
      return;
    }
    state = state.copyWith(selectedOptionId: optionId);
  }

  /// Confirma la decision de la etapa actual. Devuelve true si fue correcta.
  bool confirm() {
    final CaseStep? step = state.currentStep;
    final String? selected = state.selectedOptionId;
    if (step == null || selected == null || state.answered) {
      return false;
    }
    final bool correct = step.isCorrect(selected);
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
      stepIndex: state.stepIndex + 1,
      answered: false,
      clearSelection: true,
    );
  }
}
