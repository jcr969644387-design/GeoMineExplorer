import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/entities/student_progress.dart';
import '../providers.dart';
import '../widgets/geo_card.dart';
import '../widgets/geo_logo.dart';
import 'field_guide_view.dart';
import 'home_shell.dart';
import 'settings_view.dart';

/// Pantalla de inicio.
///
/// Existe para responder en tres segundos a "¿que hago con esta aplicacion?".
/// La version anterior abria directamente en una lista de minerales: correcta
/// para quien ya la conoce, muda para quien la abre por primera vez.
class HomeView extends ConsumerWidget {
  const HomeView({super.key, required this.onNavigate});

  /// Cambia de destino en la barra inferior.
  final void Function(int) onNavigate;

  /// Consejos de laboratorio. Rotan por dia del mes para que abrir la
  /// aplicacion dos veces seguidas no muestre siempre lo mismo.
  static const List<String> _tips = <String>[
    'La raya es la propiedad mas fiable de todas: el color del polvo no '
        'cambia con el tamaño del grano ni con la pátina de la superficie.',
    'Antes de medir dureza, limpia la marca con el dedo. Si desaparece, era '
        'polvo del instrumento y no un rayado real.',
    'El brillo se observa sobre superficie fresca y con luz indirecta. Una '
        'cara alterada convierte cualquier mineral en "submetálico".',
    'Cuenta direcciones de clivaje, no caras planas. Dos direcciones a 90 '
        'grados y dos a 120 grados son minerales distintos.',
    'La potencia que ves en la labor es aparente. Sin el ángulo entre la '
        'galería y la estructura, el tonelaje estimado sobra siempre.',
    'Si una prueba deja la lista de candidatos en cero, sospecha de la '
        'dureza: es la observación que más se ejecuta al revés.',
    'Acerca el imán a la muestra y prueba en varios puntos: hay minerales de '
        'magnetismo irregular que solo responden en una zona.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StudentProgress progress =
        ref.watch(progressProvider).value ?? const StudentProgress.empty();
    final ThemeData theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Estilo del tema para el resto de la pantalla. La cabecera declara el
      // suyo por separado: al desplazarla fuera de vista, unos iconos claros
      // fijos quedarian en blanco sobre fondo blanco, o sea, invisibles.
      value: theme.brightness == Brightness.dark
          ? GeoOverlay.dark
          : GeoOverlay.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _Hero(progress: progress),
            Padding(
              padding: geoScreenPadding(context, top: 22, bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const GeoSectionHeader(
                    title: 'Empieza por aquí',
                    subtitle: 'Cuatro formas de usar la aplicación según lo '
                        'que tengas delante',
                  ),
                  // Las tarjetas se alinean por arriba y cada una se mide
                  // sola. Igualar alturas con IntrinsicHeight obligaría a
                  // calcular dimensiones intrínsecas de una fila con hijos
                  // flexibles dentro de una lista de altura no acotada, que es
                  // justo el caso que Flutter no puede resolver.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.travel_explore,
                          color: GeoPalette.malachite,
                          title: 'Tengo una muestra',
                          subtitle: 'Clave determinativa paso a paso',
                          onTap: () => onNavigate(HomeShell.determinar),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.fitness_center,
                          color: GeoPalette.pyrite,
                          title: 'Quiero practicar',
                          subtitle: 'Sesiones de ocho ejercicios',
                          onTap: () => onNavigate(HomeShell.practica),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.engineering,
                          color: GeoPalette.azurite,
                          title: 'Decidir en un caso',
                          subtitle: 'Escenarios mineros encadenados',
                          onTap: () => onNavigate(HomeShell.casos),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.school,
                          color: GeoPalette.hematite,
                          title: 'Consultar la teoría',
                          subtitle: 'Guía técnica de referencia',
                          onTap: () => Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const FieldGuideView(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  GeoSectionHeader(
                    title: 'Contenido disponible',
                    subtitle: 'Todo funciona sin conexión, dentro de la mina '
                        'también',
                    trailing: TextButton(
                      onPressed: () => onNavigate(HomeShell.catalogo),
                      child: const Text('Ver todo'),
                    ),
                  ),
                  const _CatalogStats(),
                  const SizedBox(height: 26),
                  const GeoSectionHeader(
                    title: 'Consejo de laboratorio',
                    subtitle: 'Cambia cada día',
                  ),
                  GeoCard(
                    accentColor: GeoPalette.pyriteLight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const GeoIconBadge(
                          icon: Icons.tips_and_updates_outlined,
                          color: GeoPalette.pyrite,
                          size: 38,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _tips[DateTime.now().day % _tips.length],
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cabecera con degradado, marca y resumen de avance.
///
/// Se dibuja por detras de la barra de estado y reserva su altura con
/// `MediaQuery.paddingOf`, que es lo que evita que el titulo quede debajo del
/// notch en los telefonos con muesca o con camara perforada.
class _Hero extends StatelessWidget {
  const _Hero({required this.progress});

  final StudentProgress progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EdgeInsets inset = MediaQuery.paddingOf(context);
    final bool started = progress.totalAttempts > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // La cabecera siempre es verde oscuro, asi que sus iconos de sistema van
      // siempre en claro, sea cual sea el tema de la aplicacion.
      value: GeoOverlay.dark,
      child: Container(
        decoration: const BoxDecoration(
          gradient: GeoGradients.brand,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        // El alto de la barra de estado se reserva aqui: es lo que impide que
        // el nombre de la aplicacion quede debajo del notch.
        padding: EdgeInsets.fromLTRB(
          GeoSpacing.gutter + inset.left,
          inset.top + 14,
          GeoSpacing.gutter + inset.right,
          22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const GeoLogo(size: 30, fallbackColor: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'GeoMine Explorer',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Laboratorio geológico de bolsillo',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Ajustes',
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsView(),
                    ),
                  ),
                  icon: const Icon(Icons.tune, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: started
                  ? Row(
                      children: <Widget>[
                        _HeroStat(
                          value: '${(progress.globalAccuracy * 100).round()} %',
                          label: 'Acierto',
                        ),
                        _HeroStat(
                          value: '${progress.totalAttempts}',
                          label: 'Respuestas',
                        ),
                        _HeroStat(
                          value: '${progress.reviewedMineralIds.length}',
                          label: 'Fichas vistas',
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        const Icon(
                          Icons.flag_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aún no has registrado respuestas. Una sesión de '
                            'práctica basta para empezar a medir tu criterio.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de acceso directo.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GeoCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GeoIconBadge(icon: icon, color: color, size: 40),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Cifras del catalogo empaquetado.
class _CatalogStats extends ConsumerWidget {
  const _CatalogStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int minerals = ref.watch(mineralsProvider).value?.length ?? 0;
    final int rocks = ref.watch(rocksProvider).value?.length ?? 0;
    final int structures = ref.watch(structuresProvider).value?.length ?? 0;
    final int exercises = ref.watch(exercisesProvider).value?.length ?? 0;
    final int cases = ref.watch(casesProvider).value?.length ?? 0;

    return GeoCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: <Widget>[
          _CountCell(
            value: minerals,
            label: 'Minerales',
            color: GeoPalette.malachite,
          ),
          _CountCell(
            value: rocks,
            label: 'Rocas',
            color: GeoPalette.pyrite,
          ),
          _CountCell(
            value: structures,
            label: 'Estructuras',
            color: GeoPalette.azurite,
          ),
          _CountCell(
            value: exercises,
            label: 'Ejercicios',
            color: GeoPalette.hematite,
          ),
          _CountCell(
            value: cases,
            label: 'Casos',
            color: GeoPalette.slate,
          ),
        ],
      ),
    );
  }
}

class _CountCell extends StatelessWidget {
  const _CountCell({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
