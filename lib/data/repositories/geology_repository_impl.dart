import '../../domain/entities/exercise.dart';
import '../../domain/entities/geological_structure.dart';
import '../../domain/entities/mineral.dart';
import '../../domain/entities/mining_case.dart';
import '../../domain/entities/rock.dart';
import '../../domain/repositories/geology_repository.dart';
import '../datasources/geology_local_datasource.dart';
import '../models/geology_mappers.dart';

/// Implementacion del repositorio sobre assets locales, con cache en memoria.
///
/// El cache evita releer y reparsear los JSON en cada navegacion, que en un
/// dispositivo de gama baja se nota al abrir el catalogo repetidas veces.
class GeologyRepositoryImpl implements GeologyRepository {
  GeologyRepositoryImpl(this._dataSource);

  final GeologyLocalDataSource _dataSource;

  List<Mineral>? _minerals;
  List<Rock>? _rocks;
  List<GeologicalStructure>? _structures;
  List<Exercise>? _exercises;
  List<MiningCase>? _cases;

  @override
  Future<List<Mineral>> getMinerals() async {
    return _minerals ??= (await _dataSource.readCollection('minerals.json'))
        .map(GeologyMappers.mineralFromJson)
        .toList();
  }

  @override
  Future<List<Rock>> getRocks() async {
    return _rocks ??= (await _dataSource.readCollection('rocks.json'))
        .map(GeologyMappers.rockFromJson)
        .toList();
  }

  @override
  Future<List<GeologicalStructure>> getStructures() async {
    return _structures ??=
        (await _dataSource.readCollection('structures.json'))
            .map(GeologyMappers.structureFromJson)
            .toList();
  }

  @override
  Future<List<Exercise>> getExercises() async {
    return _exercises ??= (await _dataSource.readCollection('exercises.json'))
        .map(GeologyMappers.exerciseFromJson)
        .toList();
  }

  @override
  Future<List<MiningCase>> getCases() async {
    return _cases ??= (await _dataSource.readCollection('cases.json'))
        .map(GeologyMappers.caseFromJson)
        .toList();
  }
}
