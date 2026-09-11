import 'dart:async';
import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/app_settings.dart';

/// Momentos en los que la aplicacion responde con sonido o vibracion.
///
/// Es una lista corta a proposito. Una aplicacion que suena en cada toque
/// termina en silencio: el estudiante la apaga entera. Solo suenan las
/// acciones que cierran algo (confirmar, acertar, fallar, terminar).
enum GeoFeedback {
  /// Cambio de seleccion: solo vibracion tenue, sin sonido.
  select,

  /// Accion confirmada por el estudiante.
  tap,
  correct,
  wrong,
  complete,
}

/// Realimentacion no visual de la aplicacion.
///
/// Centralizarla en un servicio permite respetar los interruptores de ajustes
/// desde un unico sitio y, sobre todo, que el audio no sea nunca capaz de
/// romper la interfaz: cualquier fallo de reproduccion se ignora.
class FeedbackService {
  FeedbackService(this._settings);

  final AppSettings Function() _settings;

  AudioPlayer? _player;
  bool _audioBroken = false;

  /// En `flutter test` no hay plugins nativos. Crear el reproductor lanzaria
  /// una excepcion asincrona que haria fallar pruebas que nada tienen que ver
  /// con el sonido, asi que ahi se omite el audio por completo.
  static final bool _audioSupported =
      !Platform.environment.containsKey('FLUTTER_TEST');

  static const Map<GeoFeedback, String> _clips = <GeoFeedback, String>{
    GeoFeedback.tap: 'audio/tap.wav',
    GeoFeedback.correct: 'audio/correct.wav',
    GeoFeedback.wrong: 'audio/wrong.wav',
    GeoFeedback.complete: 'audio/complete.wav',
  };

  static const Map<GeoFeedback, double> _volumes = <GeoFeedback, double>{
    GeoFeedback.tap: 0.35,
    GeoFeedback.correct: 0.55,
    GeoFeedback.wrong: 0.5,
    GeoFeedback.complete: 0.6,
  };

  /// Dispara la realimentacion sin bloquear a quien la pide.
  void emit(GeoFeedback kind) {
    unawaited(_emit(kind));
  }

  Future<void> _emit(GeoFeedback kind) async {
    final AppSettings settings = _settings();
    if (settings.hapticsEnabled) {
      await _vibrate(kind);
    }
    if (settings.soundEnabled) {
      await _sound(kind);
    }
  }

  Future<void> _vibrate(GeoFeedback kind) async {
    try {
      if (kind == GeoFeedback.select) {
        await HapticFeedback.selectionClick();
      } else if (kind == GeoFeedback.tap) {
        await HapticFeedback.lightImpact();
      } else if (kind == GeoFeedback.wrong) {
        await HapticFeedback.heavyImpact();
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (error) {
      // Hay dispositivos sin motor de vibracion; no es motivo para nada mas.
      return;
    }
  }

  Future<void> _sound(GeoFeedback kind) async {
    final String? clip = _clips[kind];
    if (clip == null || !_audioSupported || _audioBroken) {
      return;
    }
    try {
      AudioPlayer? player = _player;
      if (player == null) {
        player = AudioPlayer(playerId: 'geomine_feedback');
        // Modo de baja latencia: son tonos de una decima de segundo, no
        // musica; con el reproductor normal el retardo se nota.
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        _player = player;
      }
      await player.stop();
      await player.play(AssetSource(clip), volume: _volumes[kind] ?? 0.5);
    } catch (error) {
      // El sonido es un adorno. Si el dispositivo no puede reproducirlo se
      // desactiva para el resto de la sesion en lugar de reintentar en cada
      // respuesta.
      _audioBroken = true;
    }
  }

  Future<void> dispose() async {
    final AudioPlayer? player = _player;
    _player = null;
    if (player == null) {
      return;
    }
    try {
      await player.dispose();
    } catch (error) {
      return;
    }
  }
}
