import 'package:flutter/material.dart';

import '../presentation/views/home_shell.dart';
import 'theme.dart';

/// Raiz de la aplicacion.
class GeoMineExplorerApp extends StatelessWidget {
  const GeoMineExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoMine Explorer',
      debugShowCheckedModeBanner: false,
      theme: GeoTheme.light(),
      darkTheme: GeoTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
