import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dibujo de borde a borde: el contenido pasa por detras de la barra de
  // estado y de la barra de gestos, y cada pantalla reserva ese espacio con
  // SafeArea. Es lo que evita que el titulo quede bajo el notch, y ademas es
  // el modo obligatorio a partir de Android 15.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // La aplicacion se usa con la muestra en una mano y el telefono en la otra:
  // el apaisado no aporta nada y descoloca las fichas.
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: GeoMineExplorerApp(),
    ),
  );
}
