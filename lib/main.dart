import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dibujo de borde a borde: el contenido pasa por detras de la barra de
  // estado y de la barra de gestos, y cada pantalla reserva ese espacio con
  // geoScreenPadding o con el SafeArea de la barra inferior. Es lo que evita
  // que un titulo quede bajo el notch o un boton bajo la barra de navegacion,
  // y ademas es el modo obligatorio a partir de Android 15.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Estilo inicial, antes de que se pinte la primera pantalla. Declara el
  // color de los iconos del sistema ademas de la transparencia: con barras
  // transparentes y sin esto, los botones de atras/inicio/recientes pueden
  // dibujarse en blanco sobre el fondo claro de la aplicacion.
  SystemChrome.setSystemUIOverlayStyle(GeoOverlay.light);

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
