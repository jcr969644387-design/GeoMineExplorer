import 'package:flutter/material.dart';

import 'cases_view.dart';
import 'identification_view.dart';
import 'library_view.dart';
import 'practice_view.dart';
import 'progress_view.dart';

/// Contenedor de navegacion principal.
///
/// Cinco destinos fijos y planos: en una app de consulta rapida durante una
/// practica de laboratorio, cualquier jerarquia adicional cuesta tiempo que el
/// estudiante no tiene con la muestra en la mano.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const List<Widget> _views = <Widget>[
    LibraryView(),
    IdentificationView(),
    PracticeView(),
    CasesView(),
    ProgressView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _views),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) => setState(() => _index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
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
    );
  }
}
