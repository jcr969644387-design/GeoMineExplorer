import '../entities/exercise.dart';
import '../entities/geological_structure.dart';
import '../entities/mineral.dart';
import '../entities/mining_case.dart';
import '../entities/rock.dart';

/// Contrato de acceso al contenido geologico.
///
/// El dominio no sabe si el contenido viene de un asset local, de una API o de
/// una base de datos: esa es exactamente la razon de existir del Repository
/// Pattern aqui, porque el MVP es offline y la version 2 sincronizara catálogos.
abstract class GeologyRepository {
  Future<List<Mineral>> getMinerals();

  Future<List<Rock>> getRocks();

  Future<List<GeologicalStructure>> getStructures();

  Future<List<Exercise>> getExercises();

  Future<List<MiningCase>> getCases();
}
