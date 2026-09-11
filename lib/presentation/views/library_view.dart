import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/geological_structure.dart';
import '../../domain/entities/mineral.dart';
import '../../domain/entities/rock.dart';
import '../providers.dart';
import '../services/feedback_service.dart';
import '../widgets/geo_card.dart';
import '../widgets/sample_swatch.dart';
import 'catalog_detail_views.dart';
import 'mineral_detail_view.dart';

/// Biblioteca geologica: minerales, rocas y estructuras.
///
/// Es la unica pantalla de consulta de la aplicacion. Todo lo demas obliga a
/// decidir; aqui se viene a contrastar una duda concreta, por eso el buscador
/// esta siempre visible y no oculto tras un icono.
class LibraryView extends ConsumerStatefulWidget {
  const LibraryView({super.key});

  @override
  ConsumerState<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends ConsumerState<LibraryView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(String text) =>
      _query.isEmpty || text.toLowerCase().contains(_query.toLowerCase());

  void _open(Widget page) {
    ref.read(feedbackProvider).emit(GeoFeedback.tap);
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteca geológica'),
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            indicatorColor: theme.colorScheme.primary,
            dividerColor: theme.colorScheme.outline,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const <Widget>[
              Tab(text: 'Minerales'),
              Tab(text: 'Rocas'),
              Tab(text: 'Estructuras'),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GeoSpacing.gutter,
                14,
                GeoSpacing.gutter,
                4,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (String value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, fórmula o propiedad',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                  isDense: true,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.6,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _buildMinerals(),
                  _buildRocks(),
                  _buildStructures(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinerals() {
    final AsyncValue<List<Mineral>> minerals = ref.watch(mineralsProvider);
    return minerals.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stack) =>
          _ErrorState(message: error.toString()),
      data: (List<Mineral> items) {
        final List<Mineral> filtered = items
            .where((Mineral mineral) => _matches(
                  '${mineral.name} ${mineral.formula} ${mineral.group} '
                  '${mineral.streak} ${mineral.colors.join(' ')} '
                  '${mineral.economicUse}',
                ))
            .toList();
        if (filtered.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            GeoSpacing.gutter,
            14,
            GeoSpacing.gutter,
            28,
          ),
          itemCount: filtered.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _ResultCount(
                count: filtered.length,
                singular: 'muestra mineral',
                plural: 'muestras minerales',
              );
            }
            final Mineral mineral = filtered[index - 1];
            return GeoCard(
              padding: const EdgeInsets.all(14),
              onTap: () => _open(MineralDetailView(mineral: mineral)),
              child: Row(
                children: <Widget>[
                  SampleSwatch.forMineral(mineral, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                mineral.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            GeoTag(label: mineral.group),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${mineral.formula}  ·  dureza '
                          '${mineral.hardnessLabel}  ·  raya ${mineral.streak}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRocks() {
    final AsyncValue<List<Rock>> rocks = ref.watch(rocksProvider);
    return rocks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stack) =>
          _ErrorState(message: error.toString()),
      data: (List<Rock> items) {
        final List<Rock> filtered = items
            .where((Rock rock) => _matches(
                  '${rock.name} ${rock.type.label} ${rock.texture} '
                  '${rock.composition.join(' ')} ${rock.classification}',
                ))
            .toList();
        if (filtered.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            GeoSpacing.gutter,
            14,
            GeoSpacing.gutter,
            28,
          ),
          itemCount: filtered.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _ResultCount(
                count: filtered.length,
                singular: 'roca',
                plural: 'rocas',
              );
            }
            final Rock rock = filtered[index - 1];
            return GeoCard(
              padding: const EdgeInsets.all(14),
              onTap: () => _open(RockDetailView(rock: rock)),
              child: Row(
                children: <Widget>[
                  SampleSwatch(
                    hexColor: rock.displayColor,
                    metallic: false,
                    size: 52,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          rock.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: <Widget>[
                            GeoTag(
                              label: rock.type.label,
                              color: GeoPalette.malachite,
                            ),
                            if (rock.grainSize.isNotEmpty)
                              GeoTag(
                                label: _firstWords(rock.grainSize),
                                color: GeoPalette.slate,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStructures() {
    final AsyncValue<List<GeologicalStructure>> structures =
        ref.watch(structuresProvider);
    return structures.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stack) =>
          _ErrorState(message: error.toString()),
      data: (List<GeologicalStructure> items) {
        final List<GeologicalStructure> filtered = items
            .where((GeologicalStructure structure) => _matches(
                  '${structure.name} ${structure.category.label} '
                  '${structure.definition}',
                ))
            .toList();
        if (filtered.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            GeoSpacing.gutter,
            14,
            GeoSpacing.gutter,
            28,
          ),
          itemCount: filtered.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _ResultCount(
                count: filtered.length,
                singular: 'estructura',
                plural: 'estructuras',
              );
            }
            final GeologicalStructure structure = filtered[index - 1];
            return GeoCard(
              padding: const EdgeInsets.all(14),
              onTap: () => _open(StructureDetailView(structure: structure)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GeoIconBadge(
                    icon: _structureIcon(structure.category),
                    color: GeoPalette.azurite,
                    size: 44,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                structure.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            GeoTag(label: structure.category.label),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          structure.definition,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static IconData _structureIcon(StructureCategory category) {
    if (category == StructureCategory.falla) {
      return Icons.call_split;
    }
    if (category == StructureCategory.fractura) {
      return Icons.grid_on;
    }
    if (category == StructureCategory.pliegue) {
      return Icons.waves;
    }
    if (category == StructureCategory.contacto) {
      return Icons.compare_arrows;
    }
    return Icons.filter_hdr;
  }

  /// Recorta un texto largo para usarlo como etiqueta.
  static String _firstWords(String text) {
    final int cut = text.indexOf(',');
    final String head = cut > 0 ? text.substring(0, cut) : text;
    return head.length > 26 ? '${head.substring(0, 26)}…' : head;
  }
}

/// Cabecera de la lista con el numero de resultados.
class _ResultCount extends StatelessWidget {
  const _ResultCount({
    required this.count,
    required this.singular,
    required this.plural,
  });

  final int count;
  final String singular;
  final String plural;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$count ${count == 1 ? singular : plural}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const GeoMessage(
      icon: Icons.search_off,
      title: 'Sin coincidencias',
      message: 'Ningún elemento del catálogo coincide con la búsqueda. '
          'Prueba con la fórmula, el grupo o el color de la raya.',
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GeoMessage(
      icon: Icons.error_outline,
      color: GeoPalette.hematite,
      title: 'No se pudo cargar el catálogo',
      message: message,
    );
  }
}
