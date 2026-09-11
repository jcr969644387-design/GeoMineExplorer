import 'exercise.dart';

/// Etapa de un caso minero: narrativa, decision y explicacion.
class CaseStep {
  const CaseStep({
    required this.id,
    required this.title,
    required this.narrative,
    required this.question,
    required this.options,
    required this.explanation,
  });

  final String id;
  final String title;

  /// Informacion de campo que recibe el estudiante en esta etapa.
  final String narrative;
  final String question;
  final List<ExerciseOption> options;
  final String explanation;

  ExerciseOption get correctOption =>
      options.firstWhere((ExerciseOption option) => option.correct);

  bool isCorrect(String optionId) => correctOption.id == optionId;
}

/// Caso minero encadenado: varias decisiones sobre un mismo escenario.
class MiningCase {
  const MiningCase({
    required this.id,
    required this.title,
    required this.deposit,
    required this.difficulty,
    required this.competency,
    required this.briefing,
    required this.steps,
    required this.closing,
  });

  final String id;
  final String title;

  /// Tipo de yacimiento sobre el que trabaja el caso.
  final String deposit;
  final int difficulty;
  final String competency;

  /// Encargo inicial que sitúa al estudiante en un rol profesional.
  final String briefing;
  final List<CaseStep> steps;

  /// Idea central que debe quedar tras resolver el caso.
  final String closing;

  int get stepCount => steps.length;
}
