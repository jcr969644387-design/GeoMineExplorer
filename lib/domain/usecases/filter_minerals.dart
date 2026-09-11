import '../entities/identification_query.dart';
import '../entities/mineral.dart';

/// Propiedad que puede observarse en una muestra.
enum DiscriminatingProperty {
  luster('brillo'),
  hardness('dureza'),
  cleavage('clivaje'),
  streak('color de raya'),
  density('peso específico'),
  magnetic('magnetismo'),
  reactsHcl('reacción con HCl');

  const DiscriminatingProperty(this.label);

  final String label;
}

/// Resultado de aplicar la clave determinativa.
class IdentificationResult {
  const IdentificationResult({
    required this.candidates,
    required this.suggestedNextTest,
  });

  final List<Mineral> candidates;

  /// Prueba que mas reduciria el conjunto de candidatos.
  ///
  /// Es el nucleo pedagogico del modulo: enseña a elegir la siguiente prueba en
  /// lugar de aplicar todas mecanicamente, que es como se trabaja en campo.
  final DiscriminatingProperty? suggestedNextTest;

  bool get isResolved => candidates.length == 1;
}

/// Aplica las observaciones del estudiante sobre el catalogo de minerales.
class FilterMinerals {
  const FilterMinerals();

  IdentificationResult call(
    List<Mineral> minerals,
    IdentificationQuery query,
  ) {
    final List<Mineral> candidates = minerals
        .where((Mineral mineral) => _matches(mineral, query))
        .toList()
      ..sort((Mineral a, Mineral b) => a.name.compareTo(b.name));

    return IdentificationResult(
      candidates: candidates,
      suggestedNextTest: _bestNextTest(candidates, query),
    );
  }

  bool _matches(Mineral mineral, IdentificationQuery query) {
    if (query.luster != null && mineral.luster != query.luster) {
      return false;
    }
    if (query.hardness != null &&
        !query.hardness!.matches(mineral.hardnessMin, mineral.hardnessMax)) {
      return false;
    }
    if (query.cleavage != null && mineral.cleavage != query.cleavage) {
      return false;
    }
    if (query.streak != null && mineral.streak != query.streak) {
      return false;
    }
    if (query.density != null &&
        !query.density!.matches(mineral.specificGravity)) {
      return false;
    }
    if (query.magnetic != null && mineral.magnetic != query.magnetic) {
      return false;
    }
    if (query.reactsHcl != null && mineral.reactsHcl != query.reactsHcl) {
      return false;
    }
    return true;
  }

  /// Elige la propiedad aun no observada que parte mejor el conjunto actual.
  ///
  /// Criterio: mayor numero de grupos distintos y, a igualdad, el grupo mas
  /// grande mas pequeño posible (se busca la particion mas equilibrada).
  DiscriminatingProperty? _bestNextTest(
    List<Mineral> candidates,
    IdentificationQuery query,
  ) {
    if (candidates.length <= 1) {
      return null;
    }

    final Map<DiscriminatingProperty, String Function(Mineral)> extractors =
        <DiscriminatingProperty, String Function(Mineral)>{
      if (query.luster == null)
        DiscriminatingProperty.luster: (Mineral m) => m.luster.name,
      if (query.hardness == null)
        DiscriminatingProperty.hardness: (Mineral m) => _hardnessKey(m),
      if (query.cleavage == null)
        DiscriminatingProperty.cleavage: (Mineral m) => m.cleavage.name,
      if (query.streak == null)
        DiscriminatingProperty.streak: (Mineral m) => m.streak,
      if (query.density == null)
        DiscriminatingProperty.density: (Mineral m) => _densityKey(m),
      if (query.magnetic == null)
        DiscriminatingProperty.magnetic: (Mineral m) => m.magnetic.toString(),
      if (query.reactsHcl == null)
        DiscriminatingProperty.reactsHcl: (Mineral m) => m.reactsHcl.toString(),
    };

    DiscriminatingProperty? best;
    int bestGroups = 1;
    int bestLargestGroup = candidates.length + 1;

    for (final MapEntry<DiscriminatingProperty, String Function(Mineral)> entry
        in extractors.entries) {
      final Map<String, int> buckets = <String, int>{};
      for (final Mineral mineral in candidates) {
        final String key = entry.value(mineral);
        buckets[key] = (buckets[key] ?? 0) + 1;
      }
      if (buckets.length < 2) {
        continue;
      }
      final int largestGroup =
          buckets.values.reduce((int a, int b) => a > b ? a : b);
      final bool better = buckets.length > bestGroups ||
          (buckets.length == bestGroups && largestGroup < bestLargestGroup);
      if (better) {
        best = entry.key;
        bestGroups = buckets.length;
        bestLargestGroup = largestGroup;
      }
    }
    return best;
  }

  String _densityKey(Mineral mineral) {
    for (final DensityBand band in DensityBand.values) {
      if (band.matches(mineral.specificGravity)) {
        return band.name;
      }
    }
    return 'sin_dato';
  }

  String _hardnessKey(Mineral mineral) {
    for (final HardnessBand band in HardnessBand.values) {
      if (band.matches(mineral.hardnessMin, mineral.hardnessMax)) {
        return band.name;
      }
    }
    return 'sin_dato';
  }
}
