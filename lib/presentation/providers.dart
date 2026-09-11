import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/geology_local_datasource.dart';
import '../data/datasources/progress_local_datasource.dart';
import '../data/datasources/settings_local_datasource.dart';
import '../data/repositories/geology_repository_impl.dart';
import '../data/repositories/progress_repository_impl.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/identification_query.dart';
import '../domain/entities/mineral.dart';
import '../domain/entities/student_progress.dart';
import '../domain/repositories/geology_repository.dart';
import '../domain/repositories/progress_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/usecases/filter_minerals.dart';
import 'services/feedback_service.dart';
import 'viewmodels/case_view_model.dart';
import 'viewmodels/identification_view_model.dart';
import 'viewmodels/practice_view_model.dart';
import 'viewmodels/progress_view_model.dart';
import 'viewmodels/settings_view_model.dart';

// ---------------------------------------------------------------------------
// Fuentes de datos y repositorios
//
// Riverpod actua como contenedor de inyeccion de dependencias: la vista nunca
// construye un repositorio, solo lo pide. Esto permite sustituirlos por dobles
// de prueba con `overrideWithValue` sin tocar una linea de UI.
// ---------------------------------------------------------------------------

final geologyLocalDataSourceProvider = Provider<GeologyLocalDataSource>(
  (ref) => const AssetGeologyLocalDataSource(),
);

final progressLocalDataSourceProvider = Provider<ProgressLocalDataSource>(
  (ref) => const SharedPrefsProgressLocalDataSource(),
);

final geologyRepositoryProvider = Provider<GeologyRepository>(
  (ref) => GeologyRepositoryImpl(ref.watch(geologyLocalDataSourceProvider)),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepositoryImpl(ref.watch(progressLocalDataSourceProvider)),
);

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) => const SharedPrefsSettingsLocalDataSource(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider)),
);

// ---------------------------------------------------------------------------
// Preferencias y realimentacion
// ---------------------------------------------------------------------------

final settingsProvider = StateNotifierProvider<SettingsViewModel, AppSettings>(
  (ref) => SettingsViewModel(ref.watch(settingsRepositoryProvider)),
);

/// Sonido y vibracion.
///
/// El servicio lee los ajustes en el momento de sonar, no al construirse: asi
/// apagar el sonido surte efecto en la misma pantalla, sin recrear nada.
final feedbackProvider = Provider<FeedbackService>((ref) {
  final FeedbackService service =
      FeedbackService(() => ref.read(settingsProvider));
  ref.onDispose(service.dispose);
  return service;
});

// ---------------------------------------------------------------------------
// Contenido geologico
// ---------------------------------------------------------------------------

final mineralsProvider = FutureProvider(
  (ref) => ref.watch(geologyRepositoryProvider).getMinerals(),
);

final rocksProvider = FutureProvider(
  (ref) => ref.watch(geologyRepositoryProvider).getRocks(),
);

final structuresProvider = FutureProvider(
  (ref) => ref.watch(geologyRepositoryProvider).getStructures(),
);

final exercisesProvider = FutureProvider(
  (ref) => ref.watch(geologyRepositoryProvider).getExercises(),
);

final casesProvider = FutureProvider(
  (ref) => ref.watch(geologyRepositoryProvider).getCases(),
);

/// Colores de raya disponibles, derivados del propio catalogo.
///
/// Se calculan en lugar de escribirse a mano para que al ampliar el catalogo el
/// determinador ofrezca automaticamente las nuevas opciones.
final streakOptionsProvider = Provider<List<String>>((ref) {
  final List<Mineral> minerals =
      ref.watch(mineralsProvider).value ?? <Mineral>[];
  final Set<String> streaks =
      minerals.map((Mineral mineral) => mineral.streak).toSet();
  final List<String> sorted = streaks.toList()..sort();
  return sorted;
});

// ---------------------------------------------------------------------------
// Avance del estudiante
// ---------------------------------------------------------------------------

final progressProvider =
    StateNotifierProvider<ProgressViewModel, AsyncValue<StudentProgress>>(
  (ref) => ProgressViewModel(ref.watch(progressRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Determinador de minerales
// ---------------------------------------------------------------------------

final identificationQueryProvider =
    StateNotifierProvider<IdentificationViewModel, IdentificationQuery>(
  (ref) => IdentificationViewModel(),
);

/// Resultado de la clave determinativa para las observaciones actuales.
final identificationResultProvider =
    Provider<AsyncValue<IdentificationResult>>((ref) {
  final AsyncValue<List<Mineral>> minerals = ref.watch(mineralsProvider);
  final IdentificationQuery query = ref.watch(identificationQueryProvider);
  return minerals.whenData(
    (List<Mineral> list) => const FilterMinerals()(list, query),
  );
});

// ---------------------------------------------------------------------------
// Practica y casos
// ---------------------------------------------------------------------------

/// La sesion de practica se descarta al salir de la pantalla (`autoDispose`):
/// abandonar a mitad de camino y volver debe iniciar una sesion nueva, no
/// retomar un estado a medias que el estudiante ya no recuerda.
final practiceProvider =
    StateNotifierProvider.autoDispose<PracticeViewModel, PracticeState>(
  (ref) => PracticeViewModel(
    repository: ref.watch(geologyRepositoryProvider),
    progressRepository: ref.watch(progressRepositoryProvider),
  ),
);

final caseProvider = StateNotifierProvider.autoDispose
    .family<CaseViewModel, CaseRunState, String>(
  (ref, String caseId) => CaseViewModel(
    repository: ref.watch(geologyRepositoryProvider),
    caseId: caseId,
  ),
);
