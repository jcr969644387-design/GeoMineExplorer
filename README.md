# GeoMine Explorer

Aplicación móvil educativa para estudiantes de Ingeniería de Minas. Entrena la **determinación de muestras geológicas mediante descarte sistemático** y la lectura de estructuras en clave minera.

Desarrollada dentro del proyecto *Educational Mobile Apps Factory* siguiendo su metodología de seis etapas.

---

## El problema que resuelve

Los estudiantes memorizan las propiedades de los minerales y aun así no saben determinar una muestra. El problema no es falta de información —los catálogos mineralógicos sobran— sino tres cosas distintas:

1. Reconocen la foto del apunte, pero no saben qué prueba aplicar a una muestra real.
2. Tratan dureza, raya y clivaje como datos sueltos, no como un árbol de decisión.
3. Identifican una falla en el examen y no relacionan ese dato con la veta cortada en la labor.

GeoMine Explorer se construye para esas tres fallas. No para "enseñar geología".

---

## Qué hace

| Módulo | Qué hace el estudiante |
|---|---|
| **Biblioteca** | Consulta 24 minerales, 16 rocas y 12 estructuras, con criterios diagnósticos y relevancia minera explícita |
| **Determinador** | Declara lo que observó y ve reducirse los candidatos. La app le indica **cuál es la siguiente prueba más útil** |
| **Práctica** | Sesiones de 8 ejercicios situacionales, con repaso dirigido de lo fallado |
| **Casos** | 3 casos encadenados sobre un mismo yacimiento, 13 decisiones con información parcial |
| **Avance** | Precisión por competencia. Sin rachas, sin insignias, sin puntos |

### Qué lo diferencia de un PDF o de un catálogo web

El determinador no es un buscador con filtros. Un buscador responde *«¿qué minerales son metálicos y duros?»*. El determinador responde *«de las pruebas que aún no hiciste, ¿cuál te conviene hacer ahora?»*. Esa economía de pruebas es la habilidad profesional real, y es invisible en cualquier material estático.

---

## Puesta en marcha

**Requisito: Flutter 3.32.0 o superior.**

```bash
bash tool/bootstrap.sh    # genera android/ y descarga dependencias
flutter run
```

### Generar el APK sin entorno local

Subir el repositorio a GitHub, entrar en **Actions → Build APK → Run workflow** y descargar el artefacto `geomine-explorer-apk`.

---

## Arquitectura

Flutter · Dart · Riverpod · MVVM · Repository Pattern. Tres capas con dependencias hacia adentro:

```
presentation/   views · viewmodels · widgets      Flutter
domain/         entities · usecases · contratos   Dart puro, sin Flutter
data/           datasources · mappers · repos     Assets · SharedPreferences
```

`domain/` no importa Flutter en ninguna parte, así que la lógica pedagógica —la clave determinativa, el armado de sesiones, el cálculo de competencias— se prueba en milisegundos sin levantar un binding de widgets.

**Dos dependencias en total:** `flutter_riverpod` y `shared_preferences`. Cada paquete es superficie de mantenimiento.

Detalle completo en [`docs/05_arquitectura.md`](docs/05_arquitectura.md).

---

## Privacidad

La aplicación **no recoge ningún dato**. Sin cuentas, sin red, sin permisos de Android, sin telemetría. El progreso se guarda solo en el dispositivo y el usuario puede borrarlo desde la propia app.

No es una omisión: el usuario es población estudiantil, en parte menor de edad. No recolectar nada elimina la categoría entera de problema y no cuesta ninguna funcionalidad.

---

## Pruebas

```bash
flutter test                      # unitarias, de viewmodel y de widget
python tool/validate_content.py   # integridad del catálogo geológico
```

El contenido se valida en CI igual que el código: un ejercicio con dos respuestas correctas no rompe la compilación, pero enseña algo equivocado.

---

## Documentación

| Documento | Contenido |
|---|---|
| [`01_analisis_educativo.md`](docs/01_analisis_educativo.md) | Problema, usuario, competencias, diferenciación y **riesgos asumidos** |
| [`02_validacion_academica.md`](docs/02_validacion_academica.md) | Fidelidad disciplinar y límites reales de una clave macroscópica |
| [`03_diseno_ux.md`](docs/03_diseno_ux.md) | Flujo, interacción y por qué **no hay gamificación** |
| [`04_mvp.md`](docs/04_mvp.md) | Alcance, exclusiones y **criterio de fracaso declarado** |
| [`05_arquitectura.md`](docs/05_arquitectura.md) | Decisiones técnicas y sus motivos |
| [`06_ia.md`](docs/06_ia.md) | Por qué el MVP **no lleva IA** y bajo qué condiciones la llevaría |
| [`07_plan_qa.md`](docs/07_plan_qa.md) | Estrategia de pruebas y qué queda sin cubrir |
| [`08_devops.md`](docs/08_devops.md) | CI/CD, compilación y publicación |

---

## Limitaciones conocidas

Están documentadas en detalle, pero conviene que se vean desde el README:

1. **No sustituye la muestra real.** Enseña a elegir e interpretar pruebas, no a ejecutarlas. Es complemento del laboratorio, no reemplazo.
2. **Muestras esquemáticas, no fotografías.** Entrena el criterio determinativo, no el ojo. La fotografía validada por un docente es la prioridad de V2.
3. **Catálogo parcial.** 18 minerales citados como confusión frecuente aparecen como texto sin ficha propia.
4. **Visualización espacial limitada.** La dificultad 2D→3D, la mejor documentada de la carrera, se atiende solo con texto.
5. **Requiere revisión docente antes de uso real.** Ningún test automático detecta un dato geológico incorrecto.

---

## Licencia

MIT. Ver [`LICENSE`](LICENSE).
