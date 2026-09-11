/// Modulo de practica al que pertenece un ejercicio.
enum ExerciseModule {
  identificacion('Identificación de minerales'),
  clasificacion('Clasificación de rocas'),
  estructuras('Interpretación estructural');

  const ExerciseModule(this.label);

  final String label;

  static ExerciseModule fromKey(String key) {
    switch (key) {
      case 'identificacion':
        return ExerciseModule.identificacion;
      case 'clasificacion':
        return ExerciseModule.clasificacion;
      case 'estructuras':
        return ExerciseModule.estructuras;
      default:
        throw ArgumentError('Módulo desconocido: $key');
    }
  }
}

/// Alternativa de respuesta de un ejercicio.
class ExerciseOption {
  const ExerciseOption({
    required this.id,
    required this.text,
    required this.correct,
  });

  final String id;
  final String text;
  final bool correct;
}

/// Ejercicio situacional: siempre enmarcado en una escena de trabajo real.
class Exercise {
  const Exercise({
    required this.id,
    required this.module,
    required this.competency,
    required this.difficulty,
    required this.context,
    required this.stem,
    required this.options,
    required this.explanation,
    required this.relatedIds,
  });

  final String id;
  final ExerciseModule module;

  /// Competencia que mide este ejercicio; alimenta el panel de progreso.
  final String competency;

  /// 1 = reconocimiento, 2 = aplicacion, 3 = decision profesional.
  final int difficulty;

  /// Escena profesional en la que ocurre el ejercicio.
  final String context;
  final String stem;
  final List<ExerciseOption> options;

  /// Explicacion que se muestra siempre, se acierte o no.
  final String explanation;

  /// Ids de minerales, rocas o estructuras vinculados, para el enlace al catálogo.
  final List<String> relatedIds;

  ExerciseOption get correctOption =>
      options.firstWhere((ExerciseOption option) => option.correct);

  bool isCorrect(String optionId) => correctOption.id == optionId;
}
