import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/identification_query.dart';
import '../../domain/entities/mineral.dart';
import '../../domain/usecases/filter_minerals.dart';
import '../providers.dart';
import '../services/feedback_service.dart';
import '../widgets/geo_card.dart';
import '../widgets/sample_swatch.dart';
import 'field_guide_view.dart';
import 'mineral_detail_view.dart';

/// Determinador de minerales por propiedades observadas.
///
/// Reproduce el metodo real de laboratorio: no se pregunta "¿que mineral es?",
/// se pregunta "¿que observaste?" y la lista de candidatos se va cerrando. El
/// aprendizaje ocurre al ver como cada prueba descarta muestras.
class IdentificationView extends ConsumerWidget {
  const IdentificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final IdentificationQuery query = ref.watch(identificationQueryProvider);
    final IdentificationViewModelActions actions =
        IdentificationViewModelActions(ref);
    final AsyncValue<IdentificationResult> result =
        ref.watch(identificationResultProvider);
    final List<String> streaks = ref.watch(streakOptionsProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Determinador'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Cómo se hace cada prueba',
            icon: const Icon(Icons.help_outline, size: 22),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const FieldGuideView(),
              ),
            ),
          ),
          TextButton(
            onPressed: query.isEmpty ? null : actions.reset,
            child: const Text('Limpiar'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          GeoSpacing.gutter,
          8,
          GeoSpacing.gutter,
          32,
        ),
        children: <Widget>[
          Text(
            'Declara solo lo que realmente observaste. La clave funciona con '
            'información parcial, igual que en campo.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          result.when(
            loading: () => const SizedBox.shrink(),
            error: (Object error, StackTrace stack) => const SizedBox.shrink(),
            data: (IdentificationResult data) =>
                _ResultHeader(result: data, criteria: query.activeCriteria),
          ),
          const SizedBox(height: 20),
          _ChoiceBlock<LusterType>(
            step: 1,
            title: 'Brillo',
            hint: 'Primera bifurcación: ¿parece metal o no?',
            options: LusterType.values,
            labelOf: (LusterType value) => value.label,
            selected: query.luster,
            onSelected: actions.setLuster,
          ),
          _ChoiceBlock<HardnessBand>(
            step: 2,
            title: 'Dureza',
            hint: 'Prueba de rayado, no un número exacto de Mohs.',
            options: HardnessBand.values,
            labelOf: (HardnessBand value) => value.label,
            selected: query.hardness,
            onSelected: actions.setHardness,
          ),
          _ChoiceBlock<String>(
            step: 3,
            title: 'Color de raya',
            hint: 'Frota la muestra sobre porcelana sin vidriar.',
            options: streaks,
            labelOf: (String value) => value,
            selected: query.streak,
            onSelected: actions.setStreak,
          ),
          _ChoiceBlock<DensityBand>(
            step: 4,
            title: 'Peso específico',
            hint: 'Sopesa la muestra en la mano y compárala con una roca '
                'común del mismo tamaño.',
            options: DensityBand.values,
            labelOf: (DensityBand value) => value.label,
            selected: query.density,
            onSelected: actions.setDensity,
          ),
          _ChoiceBlock<CleavageType>(
            step: 5,
            title: 'Clivaje',
            hint: '¿Se parte por superficies planas y repetidas?',
            options: CleavageType.values,
            labelOf: (CleavageType value) => value.label,
            selected: query.cleavage,
            onSelected: actions.setCleavage,
          ),
          _ChoiceBlock<bool>(
            step: 6,
            title: 'Magnetismo',
            hint: 'Acerca un imán a la muestra.',
            options: const <bool>[true, false],
            labelOf: (bool value) => value ? 'Atrae el imán' : 'No responde',
            selected: query.magnetic,
            onSelected: actions.setMagnetic,
          ),
          _ChoiceBlock<bool>(
            step: 7,
            title: 'Reacción con HCl',
            hint: 'Una gota de ácido clorhídrico diluido en frío.',
            options: const <bool>[true, false],
            labelOf: (bool value) => value ? 'Efervesce' : 'No reacciona',
            selected: query.reactsHcl,
            onSelected: actions.setReactsHcl,
          ),
          const SizedBox(height: 8),
          result.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stack) => Text(
              'No se pudo cargar el catálogo: $error',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            data: (IdentificationResult data) =>
                _CandidateList(candidates: data.candidates),
          ),
        ],
      ),
    );
  }
}

/// Pequeña fachada sobre el ViewModel para mantener la vista declarativa.
///
/// Ademas centraliza la realimentacion: cada observacion declarada vibra una
/// vez, y al hacerlo desde aqui ningun bloque de opciones tiene que saber que
/// existe un servicio de sonido.
class IdentificationViewModelActions {
  const IdentificationViewModelActions(this._ref);

  final WidgetRef _ref;

  void _touch() => _ref.read(feedbackProvider).emit(GeoFeedback.select);

  void setLuster(LusterType? value) {
    _touch();
    _ref.read(identificationQueryProvider.notifier).setLuster(value);
  }

  void setHardness(HardnessBand? value) {
    _touch();
    _ref.read(identificationQueryProvider.notifier).setHardness(value);
  }

  void setCleavage(CleavageType? value) {
    _touch();
    _ref.read(identificationQueryProvider.notifier).setCleavage(value);
  }

  void setStreak(String? value) {
    _touch();
    _ref.read(identificationQueryProvider.notifier).setStreak(value);
  }

  void setDensity(DensityBand? value) {
    _touch();
    _ref.read(identificationQueryProvider.notifier).setDensity(value);
  }

  void setMagnetic(bool? value) {
    _touch();
    _ref.read(identificationQueryProvider.notifier).setMagnetic(value);
  }

  void setReactsHcl(bool? value) {
    _touch();
    _ref.read(identificationQueryProvider.notifier).setReactsHcl(value);
  }

  void reset() {
    _ref.read(feedbackProvider).emit(GeoFeedback.tap);
    _ref.read(identificationQueryProvider.notifier).reset();
  }
}

/// Cabecera con el numero de candidatos y la prueba sugerida.
class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.result, required this.criteria});

  final IdentificationResult result;
  final int criteria;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int count = result.candidates.length;
    final bool resolved = result.isResolved;
    final bool impossible = count == 0;

    final Color accent = impossible
        ? GeoPalette.hematite
        : (resolved ? GeoPalette.malachite : GeoPalette.pyrite);
    final IconData icon = impossible
        ? Icons.report_problem_outlined
        : (resolved ? Icons.verified_outlined : Icons.filter_alt_outlined);

    return GeoCard(
      accentColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              GeoIconBadge(icon: icon, color: accent, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  impossible
                      ? 'Ninguna muestra cumple estas observaciones'
                      : (resolved
                          ? 'Identificación resuelta'
                          : '$count candidatos posibles'),
                  style: theme.textTheme.titleMedium?.copyWith(color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            impossible
                ? 'Alguna prueba puede estar mal ejecutada. Revisa la dureza: '
                    'es el error más frecuente, porque a veces se raya el '
                    'mineral y otras se raya el instrumento.'
                : (resolved
                    ? 'Las observaciones declaradas alcanzan para una única '
                        'muestra. Abre la ficha y verifica los criterios '
                        'diagnósticos antes de darlo por cerrado.'
                    : (result.suggestedNextTest == null
                        ? 'Estas pruebas ya no separan a los candidatos '
                            'restantes. Abre sus fichas y compara los '
                            'criterios diagnósticos: hábito, color y tacto '
                            'resuelven la mayoría de estos pares.'
                        : 'Siguiente prueba más útil: '
                            '${result.suggestedNextTest!.label}. Es la que '
                            'más reduce la lista actual.')),
            style: theme.textTheme.bodySmall,
          ),
          if (criteria == 0) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Todavía no declaraste ninguna observación.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bloque de opciones excluyentes con posibilidad de deseleccionar.
class _ChoiceBlock<T> extends StatelessWidget {
  const _ChoiceBlock({
    super.key,
    required this.step,
    required this.title,
    required this.hint,
    required this.options,
    required this.labelOf,
    required this.selected,
    required this.onSelected,
  });

  final int step;
  final String title;
  final String hint;
  final List<T> options;
  final String Function(T) labelOf;
  final T? selected;
  final void Function(T?) onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }
    final bool answered = selected != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: answered
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: answered
                    ? Icon(
                        Icons.check,
                        size: 15,
                        color: theme.colorScheme.onPrimary,
                      )
                    : Text(
                        '$step',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(hint, style: theme.textTheme.bodySmall),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final T option in options)
                  ChoiceChip(
                    label: Text(labelOf(option)),
                    selected: option == selected,
                    onSelected: (bool value) =>
                        onSelected(value ? option : null),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista de minerales aun compatibles con las observaciones.
class _CandidateList extends ConsumerWidget {
  const _CandidateList({required this.candidates});

  final List<Mineral> candidates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (candidates.isEmpty) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const GeoSectionHeader(
          title: 'Candidatos',
          subtitle: 'Abre una ficha para contrastar los criterios '
              'diagnósticos',
        ),
        for (final Mineral mineral in candidates)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GeoCard(
              padding: const EdgeInsets.all(12),
              onTap: () {
                ref.read(feedbackProvider).emit(GeoFeedback.tap);
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => MineralDetailView(mineral: mineral),
                  ),
                );
              },
              child: Row(
                children: <Widget>[
                  SampleSwatch.forMineral(mineral, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          mineral.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dureza ${mineral.hardnessLabel} · raya '
                          '${mineral.streak} · PE '
                          '${mineral.specificGravity.toStringAsFixed(1)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
