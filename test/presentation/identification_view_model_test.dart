import 'package:flutter_test/flutter_test.dart';
import 'package:geomine_explorer/domain/entities/identification_query.dart';
import 'package:geomine_explorer/domain/entities/mineral.dart';
import 'package:geomine_explorer/presentation/viewmodels/identification_view_model.dart';

void main() {
  late IdentificationViewModel viewModel;

  setUp(() => viewModel = IdentificationViewModel());
  tearDown(() => viewModel.dispose());

  test('arranca sin observaciones', () {
    expect(viewModel.state.isEmpty, isTrue);
    expect(viewModel.state.activeCriteria, 0);
  });

  test('cada observación declarada incrementa el contador', () {
    viewModel.setLuster(LusterType.metalico);
    viewModel.setHardness(HardnessBand.dura);
    viewModel.setDensity(DensityBand.pesada);
    expect(viewModel.state.activeCriteria, 3);
  });

  test('pasar null borra la observación en lugar de ignorarla', () {
    viewModel.setLuster(LusterType.metalico);
    viewModel.setLuster(null);
    expect(viewModel.state.luster, isNull);
    expect(viewModel.state.isEmpty, isTrue);
  });

  test('borrar una observación no arrastra a las demás', () {
    viewModel.setLuster(LusterType.metalico);
    viewModel.setMagnetic(true);
    viewModel.setMagnetic(null);
    expect(viewModel.state.luster, LusterType.metalico);
    expect(viewModel.state.magnetic, isNull);
  });

  test('reset vuelve al estado inicial', () {
    viewModel.setLuster(LusterType.metalico);
    viewModel.setCleavage(CleavageType.perfecto);
    viewModel.setStreak('gris plomo');
    viewModel.reset();
    expect(viewModel.state.isEmpty, isTrue);
  });

  test('copyWith conserva lo no tocado', () {
    const IdentificationQuery query = IdentificationQuery(
      luster: LusterType.metalico,
      magnetic: true,
    );
    final IdentificationQuery updated =
        query.copyWith(hardness: HardnessBand.dura);
    expect(updated.luster, LusterType.metalico);
    expect(updated.magnetic, isTrue);
    expect(updated.hardness, HardnessBand.dura);
  });
}
