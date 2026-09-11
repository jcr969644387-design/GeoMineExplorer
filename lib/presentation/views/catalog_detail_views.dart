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
        padding: geoScreenPadding(context, top: 8, bottom: 32),
        children: <Widget>[
          Row(
            children: <Widget>[
              SampleSwatch(
                hexColor: rock.displayColor,
                metallic: false,
                size: 76,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GeoTag(
                      label: rock.type.label,
                      color: GeoPalette.malachite,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rock.type.description,
                      style: theme.textTheme.bodySmall,
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
                Text('Descripción', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                PropertyRow(label: 'Textura', value: rock.texture),
                if (rock.grainSize.isNotEmpty)
                  PropertyRow(label: 'Granulometría', value: rock.grainSize),
                PropertyRow(
                  label: 'Composición',
                  value: rock.composition.join(', '),
                ),
                if (rock.classification.isNotEmpty)
                  PropertyRow(
                    label: 'Clasificación',
                    value: rock.classification,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GeoDetailCard(
            icon: Icons.search,
            accent: GeoPalette.malachite,
            title: 'Cómo reconocerla',
            child: BulletList(items: rock.identificationKeys),
          ),
          const SizedBox(height: 12),
          GeoDetailCard(
            icon: Icons.factory_outlined,
            accent: GeoPalette.pyrite,
            title: 'Lectura minera',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(rock.miningContext, style: theme.textTheme.bodyMedium),
                if (rock.hostsFor.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  Text('Hospeda', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      for (final String item in rock.hostsFor)
                        GeoTag(label: item, color: GeoPalette.pyrite),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (rock.geotechnical.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            GeoDetailCard(
              icon: Icons.construction_outlined,
              accent: GeoPalette.azurite,
              title: 'Comportamiento en la labor',
              child: Text(
                rock.geotechnical,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
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
        padding: geoScreenPadding(context, top: 8, bottom: 32),
        children: <Widget>[
          GeoTag(label: structure.category.label, color: GeoPalette.malachite),
          const SizedBox(height: 14),
          Text(structure.definition, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 22),
          GeoDetailCard(
            icon: Icons.search,
            accent: GeoPalette.malachite,
            title: 'Cómo reconocerla en la labor',
            child: BulletList(items: structure.recognitionKeys),
          ),
          if (structure.measurement.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            GeoDetailCard(
              icon: Icons.straighten,
              accent: GeoPalette.slate,
              title: 'Qué se mide y cómo',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    structure.measurement,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Parámetros que se registran',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      for (final String item in structure.keyParameters)
                        GeoTag(label: item, color: GeoPalette.slate),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          GeoDetailCard(
            icon: Icons.factory_outlined,
            accent: GeoPalette.pyrite,
            title: 'Consecuencia operativa',
            child: Text(
              structure.miningImplication,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (structure.geotechnical.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            GeoDetailCard(
              icon: Icons.construction_outlined,
              accent: GeoPalette.azurite,
              title: 'Estabilidad y sostenimiento',
              child: Text(
                structure.geotechnical,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
          const SizedBox(height: 12),
          GeoDetailCard(
            icon: Icons.report_problem_outlined,
            accent: GeoPalette.hematite,
            title: 'Error frecuente',
            child: Text(
              structure.commonError,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
