import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/reference/field_guide_content.dart';
import '../../domain/entities/guide_topic.dart';
import '../widgets/geo_card.dart';
import '../widgets/property_row.dart';

/// Guia tecnica de referencia.
///
/// Es la parte "de libro" de la aplicacion: escalas, tablas de clasificacion,
/// protocolos de prueba y glosario. El catalogo dice que es una muestra; esto
/// explica con que criterio se llego a esa conclusion.
class FieldGuideView extends StatelessWidget {
  const FieldGuideView({super.key});

  static const List<IconData> _icons = <IconData>[
    Icons.straighten,
    Icons.science_outlined,
    Icons.landscape_outlined,
    Icons.layers_outlined,
    Icons.blur_on,
    Icons.architecture,
    Icons.menu_book_outlined,
  ];

  static const List<Color> _colors = <Color>[
    GeoPalette.malachite,
    GeoPalette.azurite,
    GeoPalette.hematite,
    GeoPalette.pyrite,
    GeoPalette.malachiteLight,
    GeoPalette.slate,
    GeoPalette.graphite,
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Guía técnica')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          GeoSpacing.gutter,
          8,
          GeoSpacing.gutter,
          32,
        ),
        itemCount: kFieldGuide.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Material de consulta rápida. Ninguna de estas tablas '
                'sustituye a la práctica de laboratorio: sirven para no '
                'depender de la memoria cuando se tiene la muestra delante.',
                style: theme.textTheme.bodySmall,
              ),
            );
          }
          final GuideTopic topic = kFieldGuide[index - 1];
          final int slot = (index - 1) % _icons.length;
          return GeoCard(
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => _GuideTopicView(topic: topic),
              ),
            ),
            child: Row(
              children: <Widget>[
                GeoIconBadge(icon: _icons[slot], color: _colors[slot]),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(topic.title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 3),
                      Text(topic.summary, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Desarrollo de un tema de la guia.
class _GuideTopicView extends StatelessWidget {
  const _GuideTopicView({required this.topic});

  final GuideTopic topic;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          GeoSpacing.gutter,
          8,
          GeoSpacing.gutter,
          32,
        ),
        itemCount: topic.sections.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(topic.summary, style: theme.textTheme.bodyLarge),
            );
          }
          return _SectionCard(section: topic.sections[index - 1]);
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final GuideSection section;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GeoCard(
      accentColor: GeoPalette.malachite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(section.heading, style: theme.textTheme.titleMedium),
          if (section.body.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(section.body, style: theme.textTheme.bodyMedium),
          ],
          if (section.bullets.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            BulletList(items: section.bullets),
          ],
          if (section.rows.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            ...section.rows.map(
              (GuideRow row) => PropertyRow(
                label: row.label,
                value: row.value,
                labelWidth: 150,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
