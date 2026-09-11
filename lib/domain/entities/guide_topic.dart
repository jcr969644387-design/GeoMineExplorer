/// Fila de una tabla de referencia de la guia tecnica.
class GuideRow {
  const GuideRow(this.label, this.value);

  final String label;
  final String value;
}

/// Bloque dentro de un tema de la guia.
///
/// Admite las tres formas en que se presenta el contenido tecnico: parrafo
/// explicativo, lista de criterios y tabla. Un mismo bloque puede usar las
/// tres, que es como estan escritos los manuales de laboratorio.
class GuideSection {
  const GuideSection({
    required this.heading,
    this.body = '',
    this.bullets = const <String>[],
    this.rows = const <GuideRow>[],
  });

  final String heading;
  final String body;
  final List<String> bullets;
  final List<GuideRow> rows;
}

/// Tema de la guia tecnica de referencia.
class GuideTopic {
  const GuideTopic({
    required this.id,
    required this.title,
    required this.summary,
    required this.sections,
  });

  final String id;
  final String title;

  /// Una linea que explica para que sirve el tema, no de que trata.
  final String summary;
  final List<GuideSection> sections;
}
