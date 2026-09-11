import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/entities/geological_structure.dart';
import '../../domain/entities/rock.dart';
import '../widgets/geo_card.dart';
import '../widgets/property_row.dart';
import '../widgets/sample_swatch.dart';

/// Ficha de una roca.
class RockDetailView extends StatelessWidget {
  const RockDetailView({super.key, required this.rock});

  final Rock rock;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(rock.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Row(
            children: <Widget>[
              SampleSwatch(
                  hexColor: rock.displayColor, metallic: false, size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GeoTag(
                        label: rock.type.label, color: GeoPalette.malachite),
                    const SizedBox(height: 8),
                    Text(rock.type.description,
                        style: theme.textTheme.bodySmall),
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
                Text('Descripción', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                PropertyRow(label: 'Textura', value: rock.texture),
                PropertyRow(
                    label: 'Composición', value: rock.composition.join(', ')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GeoCard(
            accentColor: GeoPalette.malachite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Cómo reconocerla', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                BulletList(items: rock.identificationKeys),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GeoCard(
            accentColor: GeoPalette.pyrite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Lectura minera', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(rock.miningContext, style: theme.textTheme.bodyMedium),
                if (rock.hostsFor.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  Text('Hospeda',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.62),
                      )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: rock.hostsFor
                        .map((String item) =>
                            GeoTag(label: item, color: GeoPalette.pyrite))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ficha de una estructura geologica.
class StructureDetailView extends StatelessWidget {
  const StructureDetailView({super.key, required this.structure});

  final GeologicalStructure structure;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(structure.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          GeoTag(label: structure.category.label, color: GeoPalette.malachite),
          const SizedBox(height: 14),
          Text(structure.definition, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),
          GeoCard(
            accentColor: GeoPalette.malachite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Cómo reconocerla en la labor',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                BulletList(items: structure.recognitionKeys),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GeoCard(
            accentColor: GeoPalette.pyrite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Consecuencia operativa',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(structure.miningImplication,
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 14),
                Text('Parámetros que se miden',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.62),
                    )),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: structure.keyParameters
                      .map((String item) =>
                          GeoTag(label: item, color: GeoPalette.pyrite))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GeoCard(
            accentColor: GeoPalette.hematite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.report_problem_outlined,
                        size: 18, color: GeoPalette.hematite),
                    const SizedBox(width: 8),
                    Text('Error frecuente',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: GeoPalette.hematite)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(structure.commonError, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
