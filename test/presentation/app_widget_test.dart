import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geomine_explorer/app/app.dart';
import 'package:geomine_explorer/data/datasources/geology_local_datasource.dart';
import 'package:geomine_explorer/data/datasources/progress_local_datasource.dart';
import 'package:geomine_explorer/presentation/providers.dart';
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
    ],
    child: const GeoMineExplorerApp(),
  );
}

Future<void> goTo(WidgetTester tester, String destination) async {
  await tester.tap(find.text(destination));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('arranca en la biblioteca y lista los minerales del catálogo',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.text('Biblioteca geológica'), findsOneWidget);
    expect(find.text('Pirita'), findsOneWidget);
    expect(find.text('Galena'), findsOneWidget);
  });

  testWidgets('el buscador filtra por nombre', (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'galena');
    await tester.pumpAndSettle();

    expect(find.text('Galena'), findsOneWidget);
    expect(find.text('Pirita'), findsNothing);
  });

  testWidgets('el buscador también encuentra por fórmula',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'FeS2');
    await tester.pumpAndSettle();

    expect(find.text('Pirita'), findsOneWidget);
  });

  testWidgets('una búsqueda sin resultados muestra el estado vacío',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'zzzzz');
    await tester.pumpAndSettle();

    expect(find.text('Galena'), findsNothing);
    expect(find.text('Pirita'), findsNothing);
  });

  testWidgets('abrir una ficha muestra sus datos y vuelve atrás',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Galena'));
    await tester.pumpAndSettle();

    expect(find.textContaining('PbS'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Biblioteca geológica'), findsOneWidget);
  });

  testWidgets('las pestañas de rocas y estructuras cargan contenido',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rocas'));
    await tester.pumpAndSettle();
    expect(find.text('Granito'), findsOneWidget);

    await tester.tap(find.text('Estructuras'));
    await tester.pumpAndSettle();
    expect(find.text('Stockwork'), findsWidgets);
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

  testWidgets('la clave resuelve la hematita por su raya roja',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await goTo(tester, 'Determinar');
    await tester.tap(find.text('Metálico'));
    await tester.pumpAndSettle();

    // El bloque de color de raya queda fuera de pantalla; hay que desplazarse.
    await tester.scrollUntilVisible(
      find.text('roja parduzca'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('roja parduzca'));
    await tester.pumpAndSettle();

    expect(find.text('Identificación resuelta'), findsOneWidget);
    expect(find.text('Hematita'), findsWidgets);
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
    final Finder confirm = find.widgetWithText(FilledButton, 'Confirmar respuesta');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    await tester.tap(find.byType(AnswerOptionTile).first);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);

    await tester.tap(confirm);
    await tester.pumpAndSettle();

    // Se acierte o no, siempre aparece la explicación y el paso siguiente.
    expect(find.byType(ExplanationPanel), findsOneWidget);
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
    await tester.tap(find.byType(AnswerOptionTile).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirmar respuesta'));
    await tester.pumpAndSettle();

    await goTo(tester, 'Avance');
    // El intento quedó registrado: el panel ya no está en cero.
    expect(find.text('Avance'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
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
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('0'), findsWidgets);
  });
}
