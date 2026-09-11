import 'package:flutter_test/flutter_test.dart';
import 'package:geomine_explorer/domain/entities/identification_query.dart';
import 'package:geomine_explorer/domain/entities/mineral.dart';
import 'package:geomine_explorer/domain/usecases/filter_minerals.dart';

import '../fixtures/test_data.dart';

void main() {
  const FilterMinerals filter = FilterMinerals();
  final List<Mineral> catalog = testMinerals();

  group('HardnessBand', () {
    test('un valor puntual en el límite cae en ambas bandas contiguas', () {
      // Regresión: con solapamiento estricto la galena (2,5 exacta) no caía en
      // ninguna banda y la clave devolvía cero candidatos.
      expect(HardnessBand.muyBlanda.matches(2.5, 2.5), isTrue);
      expect(HardnessBand.blanda.matches(2.5, 2.5), isTrue);
    });

    test('excluye bandas que no se solapan', () {
      expect(HardnessBand.muyBlanda.matches(6.0, 6.5), isFalse);
      expect(HardnessBand.dura.matches(6.0, 6.5), isTrue);
    });
  });

  group('FilterMinerals', () {
    test('sin observaciones devuelve el catálogo completo', () {
      final IdentificationResult result =
          filter(catalog, const IdentificationQuery());
      expect(result.candidates.length, catalog.length);
      expect(result.isResolved, isFalse);
    });

    test('el brillo parte el catálogo en dos mitades disjuntas', () {
      final int metallic = filter(
        catalog,
        const IdentificationQuery(luster: LusterType.metalico),
      ).candidates.length;
      final int nonMetallic = filter(
        catalog,
        const IdentificationQuery(luster: LusterType.noMetalico),
      ).candidates.length;
      expect(metallic + nonMetallic, catalog.length);
    });

    test('la raya roja identifica la hematita pese al aspecto metálico', () {
      final IdentificationResult result = filter(
        catalog,
        const IdentificationQuery(
          luster: LusterType.metalico,
          streak: 'roja parduzca',
        ),
      );
      expect(result.isResolved, isTrue);
      expect(result.candidates.single.id, 'hematita');
    });

    test('el magnetismo separa magnetita de hematita', () {
      final IdentificationResult result = filter(
        catalog,
        const IdentificationQuery(luster: LusterType.metalico, magnetic: true),
      );
      expect(
        result.candidates.map((Mineral m) => m.id),
        isNot(contains('hematita')),
      );
      expect(result.candidates.map((Mineral m) => m.id), contains('magnetita'));
    });

    test('la densidad descarta candidatos livianos', () {
      final IdentificationResult result = filter(
        catalog,
        const IdentificationQuery(density: DensityBand.pesada),
      );
      expect(result.candidates.map((Mineral m) => m.id), contains('galena'));
      expect(
        result.candidates.map((Mineral m) => m.id),
        isNot(contains('cuarzo')),
      );
    });

    test('observaciones contradictorias devuelven cero candidatos', () {
      final IdentificationResult result = filter(
        catalog,
        const IdentificationQuery(
          luster: LusterType.metalico,
          reactsHcl: true,
        ),
      );
      expect(result.candidates, isEmpty);
      expect(result.suggestedNextTest, isNull);
    });

    test('sugiere una prueba mientras haya más de un candidato', () {
      final IdentificationResult result = filter(
        catalog,
        const IdentificationQuery(luster: LusterType.metalico),
      );
      expect(result.candidates.length, greaterThan(1));
      expect(result.suggestedNextTest, isNotNull);
      // La prueba sugerida nunca puede ser una ya declarada.
      expect(result.suggestedNextTest, isNot(DiscriminatingProperty.luster));
    });

    test('no sugiere prueba cuando la identificación ya está resuelta', () {
      final IdentificationResult result = filter(
        catalog,
        const IdentificationQuery(
          luster: LusterType.metalico,
          streak: 'roja parduzca',
        ),
      );
      expect(result.suggestedNextTest, isNull);
    });

    test('los candidatos se devuelven ordenados por nombre', () {
      final List<String> names = filter(catalog, const IdentificationQuery())
          .candidates
          .map((Mineral m) => m.name)
          .toList();
      final List<String> sorted = List<String>.from(names)..sort();
      expect(names, sorted);
    });
  });
}
