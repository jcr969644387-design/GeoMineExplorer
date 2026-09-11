import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia de las preferencias de la aplicacion.
///
/// Se guarda bajo una clave distinta a la del avance para que reiniciar el
/// progreso no apague los sonidos ni cambie el tema: son decisiones del
/// estudiante, no datos de aprendizaje.
abstract class SettingsLocalDataSource {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> data);
}

class SharedPrefsSettingsLocalDataSource implements SettingsLocalDataSource {
  const SharedPrefsSettingsLocalDataSource();

  static const String storageKey = 'geomine_settings_v1';

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
}

/// Implementacion en memoria, usada en pruebas.
class InMemorySettingsLocalDataSource implements SettingsLocalDataSource {
  InMemorySettingsLocalDataSource([this._data]);

  Map<String, dynamic>? _data;

  @override
  Future<Map<String, dynamic>?> read() async => _data;

  @override
  Future<void> write(Map<String, dynamic> data) async {
    _data = data;
  }
}
