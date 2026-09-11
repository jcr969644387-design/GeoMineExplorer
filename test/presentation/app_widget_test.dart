import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geomine_explorer/app/app.dart';
import 'package:geomine_explorer/data/datasources/geology_local_datasource.dart';
import 'package:geomine_explorer/data/datasources/progress_local_datasource.dart';
import 'package:geomine_explorer/data/datasources/settings_local_datasource.dart';
import 'package:geomine_explorer/presentation/providers.dart';
import 'package:geomine_explorer/presentation/views/library_view.dart';
import 'package:geomine_explorer/presentation/views/mineral_detail_view.dart';
import 'package:geomine_explorer/presentation/views/practice_view.dart';
import 'package:geomine_explorer/presentation/views/progress_view.dart';
import 'package:geomine_explorer/presentation/widgets/answer_option_tile.dart';

/// Carga los catalogos reales desde disco.
///
/// Se leen con `dart:io` y no con `rootBundle` para probar la app contra el
/// contenido que realmente se publica, sin montar el sistema de assets.
Map<String, List<Map<String, dynamic>>> loadCatalogs() {
  final Map<String, List<Map<String, dynamic>>> collections =
      <String, List<Map<String, dynamic>>>{};
  for (final String file in <String>[
    'minerals.json',
    'rocks.json',
    'structures.json',
    'exercises.json',
    'cases.json',
  ]) {
    final String raw = File('assets/data/$file').readAsStringSync();
    collections[file] = (json.decode(raw) as List<dynamic>)
        .map((dynamic item) => item as Map<String, dynamic>)
        .toList();
  }
  return collections;
}

Widget harness() {
  return ProviderScope(
    overrides: <Override>[
      geologyLocalDataSourceProvider.overrideWithValue(
        InMemoryGeologyLocalDataSource(loadCatalogs()),
      ),
      progressLocalDataSourceProvider
          .overrideWithValue(InMemoryProgressLocalDataSource()),
      settingsLocalDataSourceProvider
          .overrideWithValue(InMemorySettingsLocalDataSource()),
    ],
    child: const GeoMineExplorerApp(),
  );
}

/// Cambia de seccion pulsando la barra inferior.
///
/// El finder se acota a la [NavigationBar] a proposito: varias pantallas
/// llevan en su cabecera el mismo texto que su destino, y todas conviven en el
/// arbol dentro del IndexedStack.
Future<void> goTo(WidgetTester tester, String destination) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(destination),
    ),
  );
  await tester.pumpAndSettle();
}

/// Acota un texto a la pantalla del catalogo.
Finder inLibrary(String text) {
  return find.descendant(
    of: find.byType(LibraryView),
    matching: find.text(text),
  );
}

/// Desplaza la lista de [view] hasta dejar [target] a la vista.
///
/// Los finders de flutter_test ignoran lo que esta construido pero fuera del
/// area visible, asi que una prueba que dependa de cuantas tarjetas caben en
/// pantalla es una prueba fragil: cambia el alto de una tarjeta y falla sin
/// que nada se haya roto.
Future<void> scrollTo(WidgetTester tester, Type view, Finder target) async {
  // Se toma el último desplazable de la pantalla y no el primero: en el
  // catálogo, el primero es el PageView horizontal de las pestañas, y
  // arrastrarlo en vertical no mueve nada.
  await tester.scrollUntilVisible(
    target,
    120,
    scrollable: find
        .descendant(of: find.byType(view), matching: find.byType(Scrollable))
        .last,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la pantalla de inicio presenta la aplicación',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.text('GeoMine Explorer'), findsOneWidget);
    expect(find.text('Empieza por aquí'), findsOneWidget);
    expect(find.text('Tengo una muestra'), findsOneWidget);
  });

  testWidgets('el catálogo lista los minerales del contenido empaquetado',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Catálogo');
    expect(find.text('Biblioteca geológica'), findsOneWidget);
    expect(inLibrary('Cuarzo'), findsOneWidget);
    expect(inLibrary('Pirita'), findsOneWidget);
    // Una muestra del final del catálogo, a la que hay que desplazarse.
    await scrollTo(tester, LibraryView, inLibrary('Biotita'));
    expect(inLibrary('Biotita'), findsOneWidget);
  });

  testWidgets('el buscador filtra por nombre', (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Catálogo');
    await tester.enterText(find.byType(TextField).first, 'galena');
    await tester.pumpAndSettle();

    expect(inLibrary('Galena'), findsOneWidget);
    expect(inLibrary('Pirita'), findsNothing);
  });

  testWidgets('el buscador también encuentra por fórmula',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Catálogo');
    await tester.enterText(find.byType(TextField).first, 'FeS2');
    await tester.pumpAndSettle();

    expect(inLibrary('Pirita'), findsOneWidget);
  });

  testWidgets('una búsqueda sin resultados muestra el estado vacío',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Catálogo');
    await tester.enterText(find.byType(TextField).first, 'zzzzz');
    await tester.pumpAndSettle();

    expect(inLibrary('Galena'), findsNothing);
    expect(find.text('Sin coincidencias'), findsOneWidget);
  });

  testWidgets('abrir una ficha muestra sus datos y vuelve atrás',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Catálogo');
    // Se filtra antes de abrir: así la ficha buscada queda la primera de la
    // lista y la prueba no depende de cuántas tarjetas caben en pantalla.
    await tester.enterText(find.byType(TextField).first, 'galena');
    await tester.pumpAndSettle();
    await tester.tap(inLibrary('Galena'));
    await tester.pumpAndSettle();

    expect(find.textContaining('PbS'), findsWidgets);

    // La ficha ampliada de la v1.0.1 incorpora ambiente y paragénesis, varias
    // tarjetas más abajo.
    final Finder section = find.text('Ambiente y paragénesis');
    await scrollTo(tester, MineralDetailView, section);
    expect(section, findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Biblioteca geológica'), findsOneWidget);
  });

  testWidgets('las pestañas de rocas y estructuras cargan contenido',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Catálogo');
    // El finder se acota al catálogo: Inicio muestra un contador con esos
    // mismos rótulos.
    await tester.tap(inLibrary('Rocas'));
    await tester.pumpAndSettle();
    expect(inLibrary('Granito'), findsOneWidget);

    await tester.tap(inLibrary('Estructuras'));
    await tester.pumpAndSettle();
    expect(inLibrary('Veta tabular'), findsOneWidget);
  });

  testWidgets('el determinador reduce candidatos al declarar el brillo',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Determinar');
    expect(find.text('Determinador'), findsOneWidget);

    // Sin observaciones están los 24 minerales del catálogo.
    expect(find.text('24 candidatos posibles'), findsOneWidget);
    expect(
      find.text('Todavía no declaraste ninguna observación.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Metálico'));
    await tester.pumpAndSettle();

    // El brillo metálico deja bastantes menos candidatos, y la app indica
    // cuál es la siguiente prueba que conviene hacer.
    expect(find.text('13 candidatos posibles'), findsOneWidget);
    expect(find.textContaining('Siguiente prueba más útil'), findsOneWidget);
  });

  testWidgets('limpiar devuelve el determinador a cero observaciones',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Determinar');
    await tester.tap(find.text('Metálico'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Limpiar'));
    await tester.pumpAndSettle();

    expect(find.text('24 candidatos posibles'), findsOneWidget);
  });

  testWidgets('una sesión de práctica se responde y muestra la explicación',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Práctica');
    await tester.tap(find.text('Sesión mixta'));
    await tester.pumpAndSettle();

    expect(find.text('1 de 8'), findsOneWidget);
    expect(find.byType(AnswerOptionTile), findsWidgets);

    // El botón de confirmar está deshabilitado hasta elegir una alternativa.
    final Finder confirm = find.widgetWithText(
      FilledButton,
      'Confirmar respuesta',
    );
    await scrollTo(tester, PracticeView, confirm);
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    await tester.tap(find.byType(AnswerOptionTile).last);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);

    await tester.tap(confirm);
    await tester.pumpAndSettle();

    // Se acierte o no, siempre aparece la explicación y el paso siguiente.
    expect(find.byType(ExplanationPanel), findsOneWidget);
    await scrollTo(tester, PracticeView, find.text('Siguiente'));
    expect(find.text('Siguiente'), findsOneWidget);
  });

  testWidgets('se puede elegir un módulo concreto de práctica',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Práctica');
    await tester.tap(find.text('Clasificación de rocas'));
    await tester.pumpAndSettle();

    expect(find.byType(AnswerOptionTile), findsWidgets);
  });

  testWidgets('responder en práctica queda registrado en el avance',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Práctica');
    await tester.tap(find.text('Sesión mixta'));
    await tester.pumpAndSettle();

    final Finder confirm = find.widgetWithText(
      FilledButton,
      'Confirmar respuesta',
    );
    await scrollTo(tester, PracticeView, confirm);
    await tester.tap(find.byType(AnswerOptionTile).last);
    await tester.pumpAndSettle();
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    await goTo(tester, 'Avance');
    // El intento quedó registrado: el panel ya no está en cero.
    expect(find.text('Por competencia'), findsOneWidget);
    expect(find.text('Todavía no hay datos'), findsNothing);
  });

  testWidgets('la lista de casos se muestra y un caso se puede abrir',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Casos');
    expect(find.text('Casos mineros'), findsOneWidget);
    expect(find.text('La veta que desapareció'), findsOneWidget);

    await tester.tap(find.text('La veta que desapareció'));
    await tester.pumpAndSettle();

    expect(find.byType(AnswerOptionTile), findsWidgets);
  });

  testWidgets('el panel de avance arranca sin intentos',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Avance');
    expect(find.text('Todavía no hay datos'), findsOneWidget);
  });

  testWidgets('el sonido se puede apagar desde los ajustes',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Avance');
    await tester.tap(
      find.descendant(
        of: find.byType(ProgressView),
        matching: find.byTooltip('Ajustes'),
      ),
    );
    await tester.pumpAndSettle();

    final Finder sound = find.widgetWithText(
      SwitchListTile,
      'Tonos de respuesta',
    );
    expect(sound, findsOneWidget);
    expect(tester.widget<SwitchListTile>(sound).value, isTrue);

    await tester.tap(sound);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(sound).value, isFalse);
  });
}
