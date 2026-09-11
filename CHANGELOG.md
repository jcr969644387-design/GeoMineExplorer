# Registro de cambios

La numeración y el procedimiento de entrega están descritos en
[`docs/09_versionado.md`](docs/09_versionado.md).

---

## GeoMineExplorerV1.0.1

### Identidad

- Icono propio de la aplicación: un cristal facetado en verde malaquita con
  destello dorado, generado para el lanzador (icono adaptativo de Android) y
  reutilizado dentro de la app. Sustituye al icono por defecto de Flutter.
- El nombre visible es **GeoMine Explorer** en todas partes. `tool/bootstrap.sh`
  reescribe la etiqueta del manifiesto de Android, que `flutter create` dejaba
  como `geomine_explorer`.

### APK

- Se compila **un único APK universal**. Antes se generaban además los tres APK
  por arquitectura y se subían juntos, de modo que el archivo descargado
  contenía cuatro APK y no estaba claro cuál instalar.
- El APK se publica ya con el nombre de la entrega: `GeoMineExplorerV1.0.1.apk`,
  derivado de `pubspec.yaml` para que no pueda divergir de la versión compilada.
- El flujo de compilación falla si vuelve a producirse más de un APK.

### Corregido

- **La tarjeta base de la aplicación tomaba altura infinita.** `GeoCard` dibujaba
  su franja de color con una fila estirada (`CrossAxisAlignment.stretch`), que
  exige conocer la altura de antemano; dentro de una lista, donde la altura no
  está acotada, eso propagaba una altura infinita. En el APK de release las
  aserciones están desactivadas, así que no aparecía ningún error: la primera
  tarjeta ocupaba toda la pantalla y empujaba fuera del área visible el resto
  del contenido. Es la causa de que varias secciones se vieran vacías. Ahora la
  altura la fija el contenido y la franja se posiciona contra esa altura.

### Interfaz

- Nueva pantalla de **Inicio**: cabecera con la marca, resumen de avance,
  accesos directos a las cuatro formas de usar la aplicación, cifras del
  catálogo y un consejo de laboratorio que cambia cada día. Antes la aplicación
  abría directamente en una lista de minerales, sin contexto.
- Tema claro por defecto, paleta más luminosa, degradados de marca, tarjetas con
  esquinas de 20 px y sombra suave, iconos con color por sección, jerarquía
  tipográfica revisada y espaciados unificados en un único juego de constantes.
- Dibujo de **borde a borde** con reserva explícita del *notch* y de la barra de
  gestos: la cabecera de Inicio pasa por detrás de la barra de estado y ninguna
  pantalla queda por debajo de la muesca.
- Nueva **Guía técnica** de referencia: escala de Mohs con instrumentos de
  campo, protocolo de cada prueba determinativa, clasificación de rocas ígneas,
  sedimentarias y metamórficas, zonación de alteraciones hidrotermales, rumbo y
  buzamiento, y glosario minero-geológico.
- Fichas del catálogo ampliadas con hábito cristalino, fractura y tenacidad,
  paragénesis, ambiente de formación y comportamiento en planta (minerales);
  clasificación formal, granulometría y geotecnia (rocas); método de medición y
  consecuencia geomecánica (estructuras).
- Práctica y casos: niveles cognitivos visibles, contadores por módulo,
  explicación de cómo se evalúa y resumen de sesión con el porcentaje logrado.

### Sonido y vibración

- Cuatro tonos cortos generados para la aplicación (confirmar, acierto, error y
  cierre de sesión) y realimentación háptica en las mismas acciones.
- Nueva pantalla de **Ajustes**, accesible desde Inicio y desde Avance, donde el
  sonido y la vibración se activan o desactivan por separado, y donde se elige
  el tema (claro, oscuro o el del sistema). Las preferencias se guardan en el
  dispositivo y no se borran al reiniciar el avance.

### Interno

- Nueva capa de preferencias (entidad, fuente de datos, repositorio y
  *view model*) siguiendo la misma estructura que el avance del estudiante.
- El validador de contenido y las pruebas exigen los campos técnicos nuevos: un
  registro incompleto rompe la compilación en lugar de mostrarse a medias.
- Pruebas de widget reescritas con *finders* acotados a cada pantalla, para que
  dejen de depender de que dos secciones no compartan un mismo rótulo.

---

## GeoMineExplorerV1.0.0

Primera versión: biblioteca geológica (24 minerales, 16 rocas, 12 estructuras),
determinador por descarte, práctica situacional, casos mineros encadenados y
panel de avance por competencia.
