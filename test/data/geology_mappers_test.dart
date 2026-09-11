import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:geomine_explorer/data/models/geology_mappers.dart';
import 'package:geomine_explorer/domain/entities/exercise.dart';
import 'package:geomine_explorer/domain/entities/geological_structure.dart';
import 'package:geomine_explorer/domain/entities/mineral.dart';
import 'package:geomine_explorer/domain/entities/mining_case.dart';
import 'package:geomine_explorer/domain/entities/rock.dart';

List<Map<String, dynamic>> readAsset(String fileName) {
  final String raw = File('assets/data/$fileName').readAsStringSync();
  return (json.decode(raw) as List<dynamic>)
      .map((dynamic item) => item as Map<String, dynamic>)
      .toList();
}

void main() {
  group('GeologyMappers', () {
    test('acepta dureza escrita como entero en el JSON', () {
      // El JSON escribe 7 y no 7.0; el mapper debe normalizarlo.
      final Mineral mineral = GeologyMappers.mineralFromJson(
        <String, dynamic>{
          'id': 'x',
          'name': 'X',
          'formula': 'X',
          'group': 'G',
          'luster': 'no_metalico',
          'hardnessMin': 7,
          'hardnessMax': 7,
          'streak': 'blanca',
          'colors': <String>['incoloro'],
          'displayColor': '#FFFFFF',
          'cleavage': 'ninguno',
          'specificGravity': 3,
          'crystalSystem': 'Trigonal',
          'magnetic': false,
          'reactsHcl': false,
          'diagnostic': <String>['prueba'],
          'economicUse': 'ninguno',
          'miningRelevance': 'ninguna',
          'confusedWith': <String>[],
        },
      );
      expect(mineral.hardnessMin, 7.0);
      expect(mineral.specificGravity, 3.0);
    });

    test('rechaza una clave de brillo desconocida en vez de asumir un valor',
        () {
      expect(() => LusterType.fromKey('brillante'), throwsArgumentError);
    });
  });

  group('catálogo empaquetado', () {
    test('los 24 minerales se mapean sin error', () {
      final List<Mineral> minerals =
          readAsset('minerals.json').map(GeologyMappers.mineralFromJson).toList();
      expect(minerals.length, 24);
      expect(minerals.map((Mineral m) => m.id).toSet().length, minerals.length);
    });

    test('las rocas se mapean sin error', () {
      final List<Rock> rocks =
          readAsset('rocks.json').map(GeologyMappers.rockFromJson).toList();
      expect(rocks.length, 16);
    });

    test('las estructuras se mapean sin error', () {
      final List<GeologicalStructure> structures = readAsset('structures.json')
          .map(GeologyMappers.structureFromJson)
          .toList();
      expect(structures.length, 12);
    });

    test('cada ejercicio tiene exactamente una opción correcta', () {
      final List<Exercise> exercises = readAsset('exercises.json')
          .map(GeologyMappers.exerciseFromJson)
          .toList();
      expect(exercises, isNotEmpty);
      for (final Exercise exercise in exercises) {
        final int correct = exercise.options
            .where((ExerciseOption option) => option.correct)
            .length;
        expect(correct, 1, reason: 'Ejercicio ${exercise.id}');
        expect(exercise.options.length, greaterThanOrEqualTo(2));
        expect(exercise.explanation, isNotEmpty);
      }
    });

    test('cada etapa de caso tiene exactamente una opción correcta', () {
      final List<MiningCase> cases =
          readAsset('cases.json').map(GeologyMappers.caseFromJson).toList();
      expect(cases, isNotEmpty);
      for (final MiningCase miningCase in cases) {
        expect(miningCase.steps, isNotEmpty);
        for (final CaseStep step in miningCase.steps) {
          expect(
            step.options.where((ExerciseOption o) => o.correct).length,
            1,
            reason: '${miningCase.id} / ${step.id}',
          );
        }
      }
    });

    test('las referencias cruzadas de los ejercicios existen en el catálogo',
        () {
      final Set<String> known = <String>{
        ...readAsset('minerals.json').map((Map<String, dynamic> m) => m['id'] as String),
        ...readAsset('rocks.json').map((Map<String, dynamic> m) => m['id'] as String),
        ...readAsset('structures.json').map((Map<String, dynamic> m) => m['id'] as String),
      };
      final List<Exercise> exercises = readAsset('exercises.json')
          .map(GeologyMappers.exerciseFromJson)
          .toList();
      for (final Exercise exercise in exercises) {
        for (final String id in exercise.relatedIds) {
          expect(known, contains(id), reason: 'Ejercicio ${exercise.id}');
        }
      }
    });
  });
}
