/// Familia de la roca segun su origen.
enum RockType {
  igneaIntrusiva('Ígnea intrusiva', 'Cristalizó lentamente en profundidad'),
  igneaExtrusiva('Ígnea extrusiva', 'Cristalizó rápidamente en superficie'),
  sedimentaria('Sedimentaria', 'Formada por acumulación y litificación'),
  metamorfica('Metamórfica', 'Transformada por presión, temperatura o fluidos');

  const RockType(this.label, this.description);

  final String label;
  final String description;

  static RockType fromKey(String key) {
    switch (key) {
      case 'ignea_intrusiva':
        return RockType.igneaIntrusiva;
      case 'ignea_extrusiva':
        return RockType.igneaExtrusiva;
      case 'sedimentaria':
        return RockType.sedimentaria;
      case 'metamorfica':
        return RockType.metamorfica;
      default:
        throw ArgumentError('Tipo de roca desconocido: $key');
    }
  }
}

/// Roca del catalogo, siempre acompañada de su lectura minera.
class Rock {
  const Rock({
    required this.id,
    required this.name,
    required this.type,
    required this.texture,
    required this.composition,
    required this.displayColor,
    required this.identificationKeys,
    required this.miningContext,
    required this.hostsFor,
  });

  final String id;
  final String name;
  final RockType type;
  final String texture;
  final List<String> composition;
  final String displayColor;
  final List<String> identificationKeys;

  /// Que significa encontrar esta roca dentro de un sistema mineralizado.
  final String miningContext;
  final List<String> hostsFor;

  @override
  bool operator ==(Object other) => other is Rock && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
