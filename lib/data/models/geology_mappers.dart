import '../../domain/entities/exercise.dart';
import '../../domain/entities/geological_structure.dart';
import '../../domain/entities/mineral.dart';
import '../../domain/entities/mining_case.dart';
import '../../domain/entities/rock.dart';

/// Traduce el JSON de los assets a entidades de dominio.
///
/// Se mantiene como funciones puras y sin dependencias de Flutter para poder
/// probarlas con `dart test` sin levantar un binding de widgets.
class GeologyMappers {
  const GeologyMappers._();

  static List<String> _stringList(dynamic value) {
    if (value == null) {
      return const <String>[];
    }
    return (value as List<dynamic>)
        .map((dynamic item) => item as String)
        .toList();
  }

  /// Campo de texto opcional.
  ///
  /// Las secciones tecnicas ampliadas se incorporaron despues del primer
  /// catalogo: leerlas como opcionales evita que un registro antiguo, o un
  /// doble de prueba reducido, rompa el mapeo entero.
  static String _text(dynamic value) => value as String? ?? '';

  static double _toDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }
    return value as double;
  }

  static Mineral mineralFromJson(Map<String, dynamic> json) {
    return Mineral(
      id: json['id'] as String,
      name: json['name'] as String,
      formula: json['formula'] as String,
      group: json['group'] as String,
      luster: LusterType.fromKey(json['luster'] as String),
      hardnessMin: _toDouble(json['hardnessMin']),
      hardnessMax: _toDouble(json['hardnessMax']),
      streak: json['streak'] as String,
      colors: _stringList(json['colors']),
      displayColor: json['displayColor'] as String,
      cleavage: CleavageType.fromKey(json['cleavage'] as String),
      specificGravity: _toDouble(json['specificGravity']),
      crystalSystem: json['crystalSystem'] as String,
      magnetic: json['magnetic'] as bool,
      reactsHcl: json['reactsHcl'] as bool,
      diagnostic: _stringList(json['diagnostic']),
      economicUse: json['economicUse'] as String,
      miningRelevance: json['miningRelevance'] as String,
      confusedWith: _stringList(json['confusedWith']),
      habit: _text(json['habit']),
      fracture: _text(json['fracture']),
      associations: _stringList(json['associations']),
      environment: _text(json['environment']),
      processing: _text(json['processing']),
    );
  }

  static Rock rockFromJson(Map<String, dynamic> json) {
    return Rock(
      id: json['id'] as String,
      name: json['name'] as String,
      type: RockType.fromKey(json['type'] as String),
      texture: json['texture'] as String,
      composition: _stringList(json['composition']),
      displayColor: json['displayColor'] as String,
      identificationKeys: _stringList(json['identificationKeys']),
      miningContext: json['miningContext'] as String,
      hostsFor: _stringList(json['hostsFor']),
      classification: _text(json['classification']),
      grainSize: _text(json['grainSize']),
      geotechnical: _text(json['geotechnical']),
    );
  }

  static GeologicalStructure structureFromJson(Map<String, dynamic> json) {
    return GeologicalStructure(
      id: json['id'] as String,
      name: json['name'] as String,
      category: StructureCategory.fromKey(json['category'] as String),
      definition: json['definition'] as String,
      recognitionKeys: _stringList(json['recognitionKeys']),
      miningImplication: json['miningImplication'] as String,
      keyParameters: _stringList(json['keyParameters']),
      commonError: json['commonError'] as String,
      measurement: _text(json['measurement']),
      geotechnical: _text(json['geotechnical']),
    );
  }

  static ExerciseOption optionFromJson(Map<String, dynamic> json) {
    return ExerciseOption(
      id: json['id'] as String,
      text: json['text'] as String,
      correct: json['correct'] as bool,
    );
  }

  static List<ExerciseOption> _options(dynamic value) {
    return (value as List<dynamic>)
        .map((dynamic item) =>
            optionFromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Exercise exerciseFromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      module: ExerciseModule.fromKey(json['module'] as String),
      competency: json['competency'] as String,
      difficulty: json['difficulty'] as int,
      context: json['context'] as String,
      stem: json['stem'] as String,
      options: _options(json['options']),
      explanation: json['explanation'] as String,
      relatedIds: _stringList(json['relatedIds']),
    );
  }

  static CaseStep caseStepFromJson(Map<String, dynamic> json) {
    return CaseStep(
      id: json['id'] as String,
      title: json['title'] as String,
      narrative: json['narrative'] as String,
      question: json['question'] as String,
      options: _options(json['options']),
      explanation: json['explanation'] as String,
    );
  }

  static MiningCase caseFromJson(Map<String, dynamic> json) {
    return MiningCase(
      id: json['id'] as String,
      title: json['title'] as String,
      deposit: json['deposit'] as String,
      difficulty: json['difficulty'] as int,
      competency: json['competency'] as String,
      briefing: json['briefing'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((dynamic item) =>
              caseStepFromJson(item as Map<String, dynamic>))
          .toList(),
      closing: json['closing'] as String,
    );
  }
}
