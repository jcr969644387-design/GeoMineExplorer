import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia simple del avance del estudiante.
///
/// Se usa almacenamiento clave-valor y no una base relacional porque el volumen
/// es pequeño (decenas de intentos) y el MVP no necesita consultas complejas.
abstract class ProgressLocalDataSource {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> data);

  Future<void> clear();
}

class SharedPrefsProgressLocalDataSource implements ProgressLocalDataSource {
  const SharedPrefsProgressLocalDataSource();

  static const String storageKey = 'geomine_progress_v1';

  @override
  Future<Map<String, dynamic>?> read() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return json.decode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> write(Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, json.encode(data));
  }

  @override
  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}

/// Implementacion en memoria, usada en pruebas.
class InMemoryProgressLocalDataSource implements ProgressLocalDataSource {
  Map<String, dynamic>? _data;

  @override
  Future<Map<String, dynamic>?> read() async => _data;

  @override
  Future<void> write(Map<String, dynamic> data) async {
    _data = data;
  }

  @override
  Future<void> clear() async {
    _data = null;
  }
}
