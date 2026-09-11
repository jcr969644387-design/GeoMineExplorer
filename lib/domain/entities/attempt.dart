/// Origen de un intento registrado.
enum AttemptSource { exercise, caseStep }

/// Registro de una respuesta del estudiante.
///
/// Es la unidad minima de evidencia de aprendizaje de la aplicacion: sin estos
/// registros el panel de progreso seria decorativo.
class Attempt {
  const Attempt({
    required this.itemId,
    required this.competency,
    required this.correct,
    required this.timestamp,
    required this.source,
  });

  final String itemId;
  final String competency;
  final bool correct;
  final DateTime timestamp;
  final AttemptSource source;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'itemId': itemId,
        'competency': competency,
        'correct': correct,
        'timestamp': timestamp.toIso8601String(),
        'source': source.name,
      };

  static Attempt fromJson(Map<String, dynamic> json) {
    return Attempt(
      itemId: json['itemId'] as String,
      competency: json['competency'] as String,
      correct: json['correct'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: AttemptSource.values.firstWhere(
        (AttemptSource value) => value.name == json['source'],
        orElse: () => AttemptSource.exercise,
      ),
    );
  }
}
