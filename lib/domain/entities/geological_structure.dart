/// Familia de estructura geologica.
enum StructureCategory {
  veta('Vetas y cuerpos'),
  falla('Fallas'),
  fractura('Fracturas'),
  pliegue('Pliegues'),
  contacto('Contactos');

  const StructureCategory(this.label);

  final String label;

  static StructureCategory fromKey(String key) {
    switch (key) {
      case 'veta':
        return StructureCategory.veta;
      case 'falla':
        return StructureCategory.falla;
      case 'fractura':
        return StructureCategory.fractura;
      case 'pliegue':
        return StructureCategory.pliegue;
      case 'contacto':
        return StructureCategory.contacto;
      default:
        throw ArgumentError('Categoría de estructura desconocida: $key');
    }
  }
}

/// Estructura geologica con su implicancia operativa en mina.
class GeologicalStructure {
  const GeologicalStructure({
    required this.id,
    required this.name,
    required this.category,
    required this.definition,
    required this.recognitionKeys,
    required this.miningImplication,
    required this.keyParameters,
    required this.commonError,
    this.measurement = '',
    this.geotechnical = '',
  });

  final String id;
  final String name;
  final StructureCategory category;
  final String definition;
  final List<String> recognitionKeys;

  /// Consecuencia de esta estructura sobre el diseño o la operacion minera.
  final String miningImplication;
  final List<String> keyParameters;

  /// Error frecuente documentado, usado como material de enseñanza.
  final String commonError;

  /// Que se mide en campo y con que criterio, no solo que parametros existen.
  final String measurement;

  /// Consecuencia geomecanica: estabilidad, agua y sostenimiento.
  final String geotechnical;

  @override
  bool operator ==(Object other) =>
      other is GeologicalStructure && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
