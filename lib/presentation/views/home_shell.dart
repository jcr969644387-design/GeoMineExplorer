import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../services/feedback_service.dart';
import 'cases_view.dart';
import 'home_view.dart';
import 'identification_view.dart';
import 'library_view.dart';
import 'practice_view.dart';
import 'progress_view.dart';

/// Contenedor de navegacion principal.
///
/// Seis destinos fijos y planos: en una app de consulta rapida durante una
/// practica de laboratorio, cualquier jerarquia adicional cuesta tiempo que el
/// estudiante no tiene con la muestra en la mano. Inicio se añadio en la
/// version 1.0.1 porque la aplicacion abria directamente en una lista larga,
/// sin dar contexto de que se podia hacer con ella.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  /// Indices de los destinos. Los usan los accesos directos de Inicio.
  static const int inicio = 0;
  static const int catalogo = 1;
  static const int determinar = 2;
  static const int practica = 3;
  static const int casos = 4;
  static const int avance = 5;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = HomeShell.inicio;

  void _select(int value) {
    if (value == _index) {
      return;
    }
    ref.read(feedbackProvider).emit(GeoFeedback.select);
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = <Widget>[
      HomeView(onNavigate: _select),
      const LibraryView(),
      const IdentificationView(),
      const PracticeView(),
      const CasesView(),
      const ProgressView(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: views),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        // La barra reserva por su cuenta el hueco de los botones del telefono
        // (atras, inicio y recientes) o de la barra de gestos, asi que los
        // destinos nunca quedan debajo de ellos.
        //
        // El tamaño de letra del sistema si se limita aqui, y solo aqui: con
        // seis destinos, una fuente al 130 % hace que las etiquetas se solapen
        // entre si. El resto de la aplicacion respeta el ajuste del usuario.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Catálogo',
              ),
              NavigationDestination(
                icon: Icon(Icons.travel_explore_outlined),
                selectedIcon: Icon(Icons.travel_explore),
                label: 'Determinar',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center),
                label: 'Práctica',
              ),
              NavigationDestination(
                icon: Icon(Icons.cases_outlined),
                selectedIcon: Icon(Icons.cases),
                label: 'Casos',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Avance',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
