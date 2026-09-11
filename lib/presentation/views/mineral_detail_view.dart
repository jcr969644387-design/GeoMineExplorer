import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/mineral.dart';
import '../providers.dart';
import '../widgets/geo_card.dart';
import '../widgets/property_row.dart';
import '../widgets/sample_swatch.dart';

/// Ficha completa de un mineral.
///
/// Abrirla marca el mineral como revisado: es la señal mas barata de exposicion
/// al contenido, util para distinguir "no lo se" de "nunca lo vi".
class MineralDetailView extends ConsumerStatefulWidget {
  const MineralDetailView({super.key, required this.mineral});

  final Mineral mineral;

  @override
  ConsumerState<MineralDetailView> createState() => _MineralDetailViewState();
}

class _MineralDetailViewState extends ConsumerState<MineralDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(progressProvider.notifier)
          .markMineralReviewed(widget.mineral.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Mineral mineral = widget.mineral;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(mineral.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          GeoSpacing.gutter,
          8,
          GeoSpacing.gutter,
          32,
        ),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SampleSwatch.forMineral(mineral, size: 76),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(mineral.formula, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: <Widget>[
                        GeoTag(
                          label: mineral.group,
                          color: GeoPalette.malachite,
                        ),
                        GeoTag(
                          label: mineral.luster.label,
                          color: mineral.luster == LusterType.metalico
                              ? GeoPalette.pyrite
                              : GeoPalette.slate,
                        ),
                        GeoTag(label: mineral.crystalSystem),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          GeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Propiedades determinativas',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                PropertyRow(
                  label: 'Dureza (Mohs)',
                  value: mineral.hardnessLabel,
                ),
                PropertyRow(
                  label: 'Raya',
                  value: mineral.streak,
                  highlighted: true,
                ),
                PropertyRow(label: 'Clivaje', value: mineral.cleavage.label),
                if (mineral.fracture.isNotEmpty)
                  PropertyRow(label: 'Fractura', value: mineral.fracture),
                PropertyRow(
                  label: 'Peso específico',
                  value: mineral.specificGravity.toStringAsFixed(2),
                ),
                PropertyRow(label: 'Color', value: mineral.colors.join(', ')),
                if (mineral.habit.isNotEmpty)
                  PropertyRow(label: 'Hábito', value: mineral.habit),
                PropertyRow(
                  label: 'Magnetismo',
                  value: mineral.magnetic ? 'Magnético' : 'No magnético',
                  highlighted: mineral.magnetic,
                ),
                PropertyRow(
                  label: 'Reacción HCl',
                  value: mineral.reactsHcl ? 'Efervesce' : 'No reacciona',
                  highlighted: mineral.reactsHcl,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GeoDetailCard(
            icon: Icons.search,
            accent: GeoPalette.malachite,
            title: 'Cómo resolverlo en campo',
            child: BulletList(items: mineral.diagnostic),
          ),
          if (mineral.environment.isNotEmpty ||
              mineral.associations.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            GeoDetailCard(
              icon: Icons.terrain,
              accent: GeoPalette.azurite,
              title: 'Ambiente y paragénesis',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (mineral.environment.isNotEmpty)
                    Text(
                      mineral.environment,
                      style: theme.textTheme.bodyMedium,
                    ),
                  if (mineral.associations.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    Text(
                      'Suele aparecer junto a',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: <Widget>[
                        for (final String item in mineral.associations)
                          GeoTag(label: item, color: GeoPalette.azurite),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          GeoDetailCard(
            icon: Icons.factory_outlined,
            accent: GeoPalette.pyrite,
            title: 'Por qué importa en la operación',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  mineral.miningRelevance,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                PropertyRow(
                  label: 'Uso económico',
                  value: mineral.economicUse,
                ),
                if (mineral.processing.isNotEmpty)
                  PropertyRow(
                    label: 'En planta',
                    value: mineral.processing,
                  ),
              ],
            ),
          ),
          if (mineral.confusedWith.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            GeoDetailCard(
              icon: Icons.compare_arrows,
              accent: GeoPalette.hematite,
              title: 'Se confunde con',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Revisa estas muestras en paralelo: la mayoría de los '
                    'errores de identificación ocurren entre ellas.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      for (final String id in mineral.confusedWith)
                        GeoTag(
                          label: _prettifyId(id),
                          color: GeoPalette.hematite,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _prettifyId(String id) {
    final String spaced = id.replaceAll('_', ' ');
    return spaced.isEmpty
        ? spaced
        : spaced[0].toUpperCase() + spaced.substring(1);
  }
}

