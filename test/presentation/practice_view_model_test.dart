import 'package:flutter_test/flutter_test.dart';
import 'package:geomine_explorer/data/datasources/progress_local_datasource.dart';
import 'package:geomine_explorer/data/repositories/progress_repository_impl.dart';
import 'package:geomine_explorer/domain/entities/exercise.dart';
import 'package:geomine_explorer/domain/entities/geological_structure.dart';
import 'package:geomine_explorer/domain/entities/mineral.dart';
import 'package:geomine_explorer/domain/entities/mining_case.dart';
import 'package:geomine_explorer/domain/entities/rock.dart';
import 'package:geomine_explorer/domain/repositories/geology_repository.dart';
import 'package:geomine_explorer/presentation/viewmodels/practice_view_model.dart';

import '../fixtures/test_data.dart';

/// Repositorio de contenido controlado por la prueba.
class FakeGeologyRepository implements GeologyRepository {
  FakeGeologyRepository(this._exercises);

  final List<Exercise> _exercises;
  bool failOnExercises = false;

  @override
  Future<List<Exercise>> getExercises() async {
    if (failOnExercises) {
      throw StateError('assets corruptos');
    }
    return _exercises;
  }

  @override
  Future<List<Mineral>> getMinerals() async => <Mineral>[];

  @override
  Future<List<Rock>> getRocks() async => <Rock>[];

  @override
  Future<List<GeologicalStructure>> getStructures() async =>
      <GeologicalStructure>[];

  @override
  Future<List<MiningCase>> getCases() async => <MiningCase>[];
}

void main() {
  late FakeGeologyRepository geology;
  late ProgressRepositoryImpl progress;
  late PracticeViewModel viewModel;

  setUp(() {
    geology = FakeGeologyRepository(testExercises());
    progress = ProgressRepositoryImpl(InMemoryProgressLocalDataSource());
    viewModel = PracticeViewModel(
      repository: geology,
      progressRepository: progress,
    );
  });

  tearDown(() => viewModel.dispose());

  test('start carga una sesión y deja de estar en carga', () async {
    await viewModel.start();
    expect(viewModel.state.isLoading, isFalse);
    expect(viewModel.state.hasExercises, isTrue);
    expect(viewModel.state.current, isNotNull);
    expect(viewModel.state.error, isNull);
  });

  test('start filtrado por módulo respeta el filtro', () async {
    await viewModel.start(module: ExerciseModule.clasificacion);
    expect(viewModel.state.total, 1);
    expect(viewModel.state.module, ExerciseModule.clasificacion);
  });

  test('no se puede confirmar sin haber seleccionado', () async {
    await viewModel.start();
    expect(viewModel.confirm(), isFalse);
    expect(viewModel.state.answered, isFalse);
  });

  test('confirmar una respuesta correcta suma al marcador', () async {
    await viewModel.start();
    viewModel.select('a');
    expect(viewModel.confirm(), isTrue);
    expect(viewModel.state.correctCount, 1);
    expect(viewModel.state.answered, isTrue);
  });

  test('una respuesta incorrecta no suma pero sí marca como respondida',
      () async {
    await viewModel.start();
    viewModel.select('b');
    expect(viewModel.confirm(), isFalse);
    expect(viewModel.state.correctCount, 0);
    expect(viewModel.state.answered, isTrue);
  });

  test('no se puede cambiar la respuesta después de confirmar', () async {
    await viewModel.start();
    viewModel.select('b');
    viewModel.confirm();
    viewModel.select('a');
    expect(viewModel.state.selectedOptionId, 'b');
  });

  test('confirmar dos veces no duplica el marcador', () async {
    await viewModel.start();
    viewModel.select('a');
    viewModel.confirm();
    viewModel.confirm();
    expect(viewModel.state.correctCount, 1);
  });

  test('next no avanza si aún no se confirmó', () async {
    await viewModel.start();
    viewModel.select('a');
    viewModel.next();
    expect(viewModel.state.index, 0);
  });

  test('next limpia la selección de la pregunta siguiente', () async {
    await viewModel.start();
    viewModel.select('a');
    viewModel.confirm();
    viewModel.next();
    expect(viewModel.state.index, 1);
    expect(viewModel.state.selectedOptionId, isNull);
    expect(viewModel.state.answered, isFalse);
  });

  test('recorrer toda la sesión termina en estado finalizado', () async {
    await viewModel.start(module: ExerciseModule.identificacion);
    for (int i = 0; i < viewModel.state.total; i++) {
      viewModel.select('a');
      viewModel.confirm();
      viewModel.next();
    }
    expect(viewModel.state.isFinished, isTrue);
    expect(viewModel.state.current, isNull);
    expect(viewModel.state.completion, 1.0);
  });

  test('un fallo al leer el contenido se expone como error, sin excepción',
      () async {
    geology.failOnExercises = true;
    await viewModel.start();
    expect(viewModel.state.error, isNotNull);
    expect(viewModel.state.isLoading, isFalse);
    expect(viewModel.state.hasExercises, isFalse);
  });
}
