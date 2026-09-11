import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/geological_structure.dart';
import '../../domain/entities/mineral.dart';
import '../../domain/entities/rock.dart';
import '../providers.dart';
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteca geológica'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Minerales'),
              Tab(text: 'Rocas'),
              Tab(text: 'Estructuras'),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (String value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, fórmula o propiedad',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
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
            .where((Mineral mineral) =>
                _matches('${mineral.name} ${mineral.formula} '
                    '${mineral.group} ${mineral.streak}'))
            .toList();
        if (filtered.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            final Mineral mineral = filtered[index];
            return GeoCard(
              padding: const EdgeInsets.all(12),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => MineralDetailView(mineral: mineral),
                ),
              ),
              child: Row(
                children: <Widget>[
                  SampleSwatch.forMineral(mineral),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(mineral.name,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${mineral.formula}  ·  dureza '
                          '${mineral.hardnessLabel}  ·  raya ${mineral.streak}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
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
                '${rock.name} ${rock.type.label} ${rock.composition.join(' ')}'))
            .toList();
        if (filtered.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            final Rock rock = filtered[index];
            return GeoCard(
              padding: const EdgeInsets.all(12),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => RockDetailView(rock: rock),
                ),
              ),
              child: Row(
                children: <Widget>[
                  SampleSwatch(hexColor: rock.displayColor, metallic: false),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(rock.name,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        GeoTag(
                            label: rock.type.label,
                            color: GeoPalette.malachite),
                      ],
                    ),
                  ),
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
                '${structure.definition}'))
            .toList();
        if (filtered.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            final GeologicalStructure structure = filtered[index];
            return GeoCard(
              padding: const EdgeInsets.all(14),
              accentColor: GeoPalette.slate,
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => StructureDetailView(structure: structure),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(structure.name,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      GeoTag(label: structure.category.label),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    structure.definition,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Ningún elemento coincide con la búsqueda.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No se pudo cargar el catálogo.\n$message',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
