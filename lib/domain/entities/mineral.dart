/// Tipo de brillo observado en la muestra.
///
/// Es la primera bifurcacion de cualquier clave determinativa de mineralogia:
/// separa el universo de minerales en dos mitades manejables.
enum LusterType {
  metalico('Metálico'),
  noMetalico('No metálico');

  const LusterType(this.label);

  final String label;

  static LusterType fromKey(String key) {
    switch (key) {
      case 'metalico':
        return LusterType.metalico;
      case 'no_metalico':
        return LusterType.noMetalico;
      default:
        throw ArgumentError('Brillo desconocido: $key');
    }
  }
}

/// Calidad del clivaje (exfoliacion) de la muestra.
enum CleavageType {
  ninguno('Ausente'),
  regular('Regular'),
  perfecto('Perfecto');

  const CleavageType(this.label);

  final String label;

  static CleavageType fromKey(String key) {
    switch (key) {
      case 'ninguno':
        return CleavageType.ninguno;
      case 'regular':
        return CleavageType.regular;
      case 'perfecto':
        return CleavageType.perfecto;
      default:
        throw ArgumentError('Clivaje desconocido: $key');
    }
  }
}

/// Rangos de dureza usados en la clave determinativa.
///
/// No se pide al estudiante un valor exacto de Mohs porque en campo nunca se
/// dispone de el: se trabaja con pruebas de rayado (uña, moneda de cobre,
/// punta de acero, vidrio).
enum HardnessBand {
  muyBlanda('Se raya con la uña', 1.0, 2.5),
  blanda('Se raya con una moneda de cobre', 2.5, 3.5),
  media('Se raya con punta de acero', 3.5, 5.5),
  dura('Raya el vidrio', 5.5, 10.0);

  const HardnessBand(this.label, this.min, this.max);

  final String label;
  final double min;
  final double max;

  /// Verdadero si el rango de dureza del mineral se solapa con esta banda.
  ///
  /// El solapamiento es inclusivo a proposito: un mineral de dureza 2,5 exacta
  /// (galena) es ambiguo frente a la prueba de la moneda de cobre y debe
  /// aparecer en ambas bandas. Excluirlo por un limite cerrado haria que la
  /// clave devolviera cero candidatos ante una observacion correcta.
  bool matches(double hardnessMin, double hardnessMax) {
    return hardnessMin <= max && hardnessMax >= min;
  }
}

/// Rangos de peso especifico usados en la clave determinativa.
///
/// Corresponden a la prueba de sopesar la muestra en la mano, que es como se
/// aplica en campo: nadie lleva balanza hidrostatica a una labor.
enum DensityBand {
  ligera('Se siente liviana', 0.0, 3.0),
  media('Peso corriente', 3.0, 4.5),
  pesada('Notoriamente pesada', 4.5, 25.0);

  const DensityBand(this.label, this.min, this.max);

  final String label;
  final double min;
  final double max;

  bool matches(double specificGravity) =>
      specificGravity >= min && specificGravity <= max;
}

/// Muestra mineral del catalogo, descrita por sus propiedades determinativas.
class Mineral {
  const Mineral({
    required this.id,
    required this.name,
    required this.formula,
    required this.group,
    required this.luster,
    required this.hardnessMin,
    required this.hardnessMax,
    required this.streak,
    required this.colors,
    required this.displayColor,
    required this.cleavage,
    required this.specificGravity,
    required this.crystalSystem,
    required this.magnetic,
    required this.reactsHcl,
    required this.diagnostic,
    required this.economicUse,
    required this.miningRelevance,
    required this.confusedWith,
    this.habit = '',
    this.fracture = '',
    this.associations = const <String>[],
    this.environment = '',
    this.processing = '',
  });

  final String id;
  final String name;
  final String formula;
  final String group;
  final LusterType luster;
  final double hardnessMin;
  final double hardnessMax;
  final String streak;
  final List<String> colors;

  /// Color hexadecimal aproximado usado para dibujar la ficha de muestra.
  final String displayColor;
  final CleavageType cleavage;
  final double specificGravity;
  final String crystalSystem;
  final bool magnetic;
  final bool reactsHcl;

  /// Criterios que resuelven la identificacion en campo.
  final List<String> diagnostic;
  final String economicUse;

  /// Por que este mineral importa en una operacion minera real.
  final String miningRelevance;
  final List<String> confusedWith;

  /// Habito cristalino: la forma en que el mineral crece en la naturaleza.
  final String habit;

  /// Fractura y tenacidad, complemento del clivaje.
  final String fracture;

  /// Paragenesis: minerales con los que aparece habitualmente en la misma
  /// muestra. Ver dos de ellos juntos es, en la practica, una prueba mas.
  final List<String> associations;

  /// Ambiente de formacion y tipo de yacimiento donde se encuentra.
  final String environment;

  /// Comportamiento en planta: como se concentra o por que penaliza.
  final String processing;

  /// Verdadero si la ficha trae la seccion tecnica ampliada.
  bool get hasExtendedData => habit.isNotEmpty || environment.isNotEmpty;

  String get hardnessLabel => hardnessMin == hardnessMax
      ? hardnessMin.toStringAsFixed(1)
      : '${hardnessMin.toStringAsFixed(1)} - ${hardnessMax.toStringAsFixed(1)}';

  @override
  bool operator ==(Object other) =>
      other is Mineral && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
