import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/identification_query.dart';
import '../../domain/entities/mineral.dart';

/// ViewModel del determinador de minerales.
///
/// Solo custodia las observaciones declaradas por el estudiante; el filtrado
/// vive en el caso de uso `FilterMinerals`, que es logica de dominio pura y se
/// prueba sin Flutter.
class IdentificationViewModel extends StateNotifier<IdentificationQuery> {
  IdentificationViewModel() : super(const IdentificationQuery());

  void setLuster(LusterType? value) {
    state = value == null
        ? state.copyWith(clearLuster: true)
        : state.copyWith(luster: value);
  }

  void setHardness(HardnessBand? value) {
    state = value == null
        ? state.copyWith(clearHardness: true)
        : state.copyWith(hardness: value);
  }

  void setCleavage(CleavageType? value) {
    state = value == null
        ? state.copyWith(clearCleavage: true)
        : state.copyWith(cleavage: value);
  }

  void setStreak(String? value) {
    state = value == null
        ? state.copyWith(clearStreak: true)
        : state.copyWith(streak: value);
  }

  void setDensity(DensityBand? value) {
    state = value == null
        ? state.copyWith(clearDensity: true)
        : state.copyWith(density: value);
  }

  void setMagnetic(bool? value) {
    state = value == null
        ? state.copyWith(clearMagnetic: true)
        : state.copyWith(magnetic: value);
  }

  void setReactsHcl(bool? value) {
    state = value == null
        ? state.copyWith(clearReactsHcl: true)
        : state.copyWith(reactsHcl: value);
  }

  void reset() {
    state = const IdentificationQuery();
  }
}
