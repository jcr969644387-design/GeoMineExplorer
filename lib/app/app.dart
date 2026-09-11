import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/app_settings.dart';
import '../presentation/providers.dart';
import '../presentation/views/home_shell.dart';
import 'theme.dart';

/// Raiz de la aplicacion.
class GeoMineExplorerApp extends ConsumerWidget {
  const GeoMineExplorerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'GeoMine Explorer',
      debugShowCheckedModeBanner: false,
      theme: GeoTheme.light(),
      darkTheme: GeoTheme.dark(),
      themeMode: _themeMode(settings.theme),
      home: const HomeShell(),
    );
  }

  static ThemeMode _themeMode(ThemePreference preference) {
    if (preference == ThemePreference.oscuro) {
      return ThemeMode.dark;
    }
    if (preference == ThemePreference.sistema) {
      return ThemeMode.system;
    }
    return ThemeMode.light;
  }
}
