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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SampleSwatch.forMineral(mineral, size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(mineral.formula, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: <Widget>[
                        GeoTag(label: mineral.group),
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
          const SizedBox(height: 20),
          GeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Propiedades determinativas',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                PropertyRow(
                    label: 'Dureza (Mohs)', value: mineral.hardnessLabel),
                PropertyRow(
                    label: 'Raya', value: mineral.streak, highlighted: true),
                PropertyRow(label: 'Clivaje', value: mineral.cleavage.label),
                PropertyRow(
                  label: 'Peso específico',
                  value: mineral.specificGravity.toStringAsFixed(2),
                ),
                PropertyRow(label: 'Color', value: mineral.colors.join(', ')),
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
          GeoCard(
            accentColor: GeoPalette.malachite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Cómo resolverlo en campo',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                BulletList(items: mineral.diagnostic),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GeoCard(
            accentColor: GeoPalette.pyrite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Por qué importa en la operación',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(mineral.miningRelevance,
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                PropertyRow(label: 'Uso económico', value: mineral.economicUse),
              ],
            ),
          ),
          if (mineral.confusedWith.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            GeoCard(
              accentColor: GeoPalette.hematite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Se confunde con', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Revisa estas muestras en paralelo: la mayoría de los '
                    'errores de identificación ocurren entre ellas.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: mineral.confusedWith
                        .map((String id) => GeoTag(
                              label: _prettifyId(id),
                              color: GeoPalette.hematite,
                            ))
                        .toList(),
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
