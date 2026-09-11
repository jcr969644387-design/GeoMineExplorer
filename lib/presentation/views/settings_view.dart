import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_info.dart';
import '../../app/theme.dart';
import '../../domain/entities/app_settings.dart';
import '../providers.dart';
import '../services/feedback_service.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/geo_card.dart';
import '../widgets/geo_logo.dart';

/// Ajustes de la aplicacion.
///
/// Son pocos y todos reversibles. El sonido y la vibracion se pueden apagar
/// por completo: la aplicacion se usa en biblioteca y en clase, y una app que
/// no se puede silenciar se desinstala.
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(settingsProvider);
    final SettingsViewModel model = ref.read(settingsProvider.notifier);
    final FeedbackService feedback = ref.read(feedbackProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: geoScreenPadding(context, top: 8, bottom: 32),
        children: <Widget>[
          const GeoSectionHeader(
            title: 'Sonido y vibración',
            subtitle: 'Solo suenan las acciones que cierran algo: confirmar, '
                'acertar, fallar y terminar una sesión',
          ),
          GeoCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  value: settings.soundEnabled,
                  onChanged: (bool value) {
                    model.setSoundEnabled(value);
                    if (value) {
                      // Se reproduce el tono al activarlo: asi el estudiante
                      // sabe a que volumen suena antes de guardar nada.
                      feedback.emit(GeoFeedback.correct);
                    }
                  },
                  secondary: const GeoIconBadge(
                    icon: Icons.volume_up_outlined,
                    color: GeoPalette.malachite,
                    size: 38,
                  ),
                  title: const Text('Tonos de respuesta'),
                  subtitle: const Text(
                    'Cuatro tonos cortos, sin música de fondo',
                  ),
                ),
                const Divider(indent: 18, endIndent: 18),
                SwitchListTile(
                  value: settings.hapticsEnabled,
                  onChanged: (bool value) {
                    model.setHapticsEnabled(value);
                    if (value) {
                      feedback.emit(GeoFeedback.tap);
                    }
                  },
                  secondary: const GeoIconBadge(
                    icon: Icons.vibration,
                    color: GeoPalette.azurite,
                    size: 38,
                  ),
                  title: const Text('Vibración'),
                  subtitle: const Text(
                    'Confirmación táctil al responder y al cambiar de sección',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const GeoSectionHeader(
            title: 'Apariencia',
            subtitle: 'El tema claro es el predeterminado porque las fichas de '
                'muestra llevan color propio',
          ),
          GeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final ThemePreference option
                        in ThemePreference.values)
                      ChoiceChip(
                        label: Text(option.label),
                        selected: settings.theme == option,
                        onSelected: (bool value) {
                          if (!value) {
                            return;
                          }
                          feedback.emit(GeoFeedback.select);
                          model.setTheme(option);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const GeoSectionHeader(title: 'Acerca de'),
          GeoCard(
            accentColor: GeoPalette.malachite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const GeoLogo(size: 42),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            AppInfo.name,
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            AppInfo.release,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(AppInfo.tagline, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 10),
                Text(
                  'Todo el contenido está empaquetado en la aplicación: '
                  'funciona sin conexión y no envía datos a ningún servidor. '
                  'El avance se guarda solo en este dispositivo.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
