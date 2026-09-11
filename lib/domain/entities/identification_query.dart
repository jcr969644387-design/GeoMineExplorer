import 'mineral.dart';

/// Conjunto de observaciones que el estudiante declara en el determinador.
///
/// Todos los campos son opcionales a proposito: en campo rara vez se dispone de
/// todas las pruebas, y la clave debe funcionar con informacion parcial.
class IdentificationQuery {
  const IdentificationQuery({
    this.luster,
    this.hardness,
    this.cleavage,
    this.streak,
    this.density,
    this.magnetic,
    this.reactsHcl,
  });

  final LusterType? luster;
  final HardnessBand? hardness;
  final CleavageType? cleavage;

  /// Color de raya normalizado (texto libre proveniente de una lista cerrada).
  final String? streak;
  final DensityBand? density;
  final bool? magnetic;
  final bool? reactsHcl;

  /// Cantidad de observaciones declaradas.
  int get activeCriteria => <Object?>[
        luster,
        hardness,
        cleavage,
        streak,
        density,
        magnetic,
        reactsHcl,
      ].where((Object? value) => value != null).length;

  bool get isEmpty => activeCriteria == 0;

  IdentificationQuery copyWith({
    LusterType? luster,
    HardnessBand? hardness,
    CleavageType? cleavage,
    String? streak,
    DensityBand? density,
    bool? magnetic,
    bool? reactsHcl,
    bool clearLuster = false,
    bool clearHardness = false,
    bool clearCleavage = false,
    bool clearStreak = false,
    bool clearDensity = false,
    bool clearMagnetic = false,
    bool clearReactsHcl = false,
  }) {
    return IdentificationQuery(
      luster: clearLuster ? null : (luster ?? this.luster),
      hardness: clearHardness ? null : (hardness ?? this.hardness),
      cleavage: clearCleavage ? null : (cleavage ?? this.cleavage),
      streak: clearStreak ? null : (streak ?? this.streak),
      density: clearDensity ? null : (density ?? this.density),
      magnetic: clearMagnetic ? null : (magnetic ?? this.magnetic),
      reactsHcl: clearReactsHcl ? null : (reactsHcl ?? this.reactsHcl),
    );
  }
}
