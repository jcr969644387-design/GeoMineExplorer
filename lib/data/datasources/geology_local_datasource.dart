import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Lee los catalogos geologicos empaquetados como assets.
///
/// Se separa en una interfaz para poder sustituirla por datos en memoria
/// durante las pruebas, sin depender del sistema de assets de Flutter.
abstract class GeologyLocalDataSource {
  Future<List<Map<String, dynamic>>> readCollection(String fileName);
}

class AssetGeologyLocalDataSource implements GeologyLocalDataSource {
  const AssetGeologyLocalDataSource();

  @override
  Future<List<Map<String, dynamic>>> readCollection(String fileName) async {
    final String raw = await rootBundle.loadString('assets/data/$fileName');
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((dynamic item) => item as Map<String, dynamic>)
        .toList();
  }
}

/// Implementacion en memoria, usada en pruebas.
class InMemoryGeologyLocalDataSource implements GeologyLocalDataSource {
  const InMemoryGeologyLocalDataSource(this.collections);

  final Map<String, List<Map<String, dynamic>>> collections;

  @override
  Future<List<Map<String, dynamic>>> readCollection(String fileName) async {
    final List<Map<String, dynamic>>? data = collections[fileName];
    if (data == null) {
      throw StateError('Colección no registrada: $fileName');
    }
    return data;
  }
}
