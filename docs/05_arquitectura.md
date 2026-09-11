# Etapa 5 — Arquitectura técnica

**Herramienta:** Mobile App Architect
**Pregunta rectora:** ¿cómo desarrollar esta aplicación correctamente?

---

## 1. Arquitectura general

Tres capas, con dependencias apuntando **siempre hacia adentro**:

```
┌──────────────────────────────────────────────┐
│  presentation/   views · viewmodels · widgets │  Flutter
├──────────────────────────────────────────────┤
│  domain/         entities · usecases          │  Dart puro
│                  repositories (contratos)     │
├──────────────────────────────────────────────┤
│  data/           datasources · mappers        │  Assets / prefs
│                  repositories (implementación)│
└──────────────────────────────────────────────┘
```

`domain/` no importa Flutter en ninguna parte. Es una restricción verificable y tiene una consecuencia práctica concreta: la lógica pedagógica —la clave determinativa, el armado de sesiones, el cálculo de competencias— se prueba sin levantar un binding de widgets, en milisegundos.

### MVVM

| Elemento | Responsabilidad |
|---|---|
| **View** | Declara interfaz y despacha intenciones. Sin lógica de negocio. |
| **ViewModel** | `StateNotifier` con estado inmutable. Orquesta casos de uso y repositorios. |
| **Model** | Entidades de dominio. Inmutables. |

Los ViewModels no conocen ningún widget y reciben sus dependencias por constructor, lo que permite probarlos sin `WidgetTester`.

### Repository Pattern

El dominio declara `GeologyRepository` y `ProgressRepository` como contratos abstractos. El dominio no sabe si el contenido viene de un asset, de una API o de una base local.

Esta indirección **se gana su lugar** por dos motivos verificables en el repositorio: (a) permite sustituir el origen de datos en pruebas con una línea de `override`, que es lo que hacen los widget tests; (b) es la única modificación necesaria el día que V2 sincronice catálogos remotos, sin tocar dominio ni interfaz.

---

## 2. Stack tecnológico

| Capa | Elección | Por qué |
|---|---|---|
| Framework | **Flutter 3.32** | Exigido por el encargo; adecuado por base de código única y buen rendimiento en gama media |
| Lenguaje | **Dart 3.4+** | Null safety, `sealed`, enums con miembros |
| Estado / DI | **flutter_riverpod 2.5** | Exigido; actúa además como contenedor de inyección de dependencias |
| Persistencia | **shared_preferences 2.2** | Ver justificación abajo |
| Contenido | **JSON en assets** | Ver justificación abajo |
| Lint | **flutter_lints 4** | Reglas oficiales más reglas propias del proyecto |

**Dos dependencias en total.** Cada paquete es superficie de mantenimiento; en una aplicación educativa que debe seguir compilando dentro de dos años, esa cuenta importa más que la comodidad inmediata.

### Por qué `shared_preferences` y no SQLite o Isar

El volumen es de decenas o pocos cientos de intentos por estudiante, sin consultas relacionales: todo el análisis (`competencyScores`, `pendingReviewItemIds`) se resuelve en memoria sobre una lista. Una base embebida añadiría esquema, migraciones y una dependencia nativa para resolver un problema que no existe. Si el volumen creciera, el cambio queda contenido en `ProgressLocalDataSource`, sin tocar nada más.

### Por qué JSON en assets y no una base de contenido

El contenido geológico es **de solo lectura y se versiona con el código**. Como archivo JSON, un docente revisor puede leerlo y corregirlo en un pull request sin saber Dart, y la validación de contenido corre en CI. Ese flujo de revisión es exactamente el que el análisis académico exige.

---

## 3. Estructura de carpetas

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── theme.dart
├── domain/
│   ├── entities/          Mineral, Rock, GeologicalStructure, Exercise,
│   │                      MiningCase, IdentificationQuery, Attempt,
│   │                      StudentProgress
│   ├── repositories/      Contratos
│   └── usecases/          FilterMinerals, BuildPracticeSession
├── data/
│   ├── datasources/       Assets · SharedPreferences (+ dobles en memoria)
│   ├── models/            GeologyMappers
│   └── repositories/      Implementaciones
└── presentation/
    ├── providers.dart     Grafo de dependencias
    ├── viewmodels/
    ├── views/
    └── widgets/
```

---

## 4. Decisiones técnicas destacadas

### La lógica pedagógica vive en el dominio

`FilterMinerals` no es un filtro de lista dentro de un widget. Es un caso de uso que devuelve candidatos **y la siguiente prueba recomendada**, calculada eligiendo la propiedad no observada que mejor particiona el conjunto actual. Está en el dominio porque es la regla educativa central del producto, y por eso es directamente testeable.

### Caché de contenido en el repositorio

`GeologyRepositoryImpl` cachea las colecciones ya parseadas. Releer y reparsear cinco JSON en cada navegación se nota en un dispositivo de gama baja, que es el dispositivo objetivo.

### `autoDispose` en práctica y casos

Abandonar una sesión a la mitad y volver debe iniciar una sesión nueva, no retomar un estado intermedio que el estudiante ya no recuerda. Es una decisión pedagógica implementada como decisión de ciclo de vida.

### El ViewModel de práctica carga el progreso internamente

Una versión anterior recibía el progreso como parámetro, lo que hacía que el notifier se reconstruyera con cada respuesta registrada y se perdiera la sesión en curso. Ahora `PracticeViewModel` recibe el `ProgressRepository` y lee el progreso dentro de `start()`. Es un defecto encontrado y corregido durante la construcción, anotado aquí porque la causa —estado derivado que invalida su propio contenedor— es fácil de reintroducir.

### La carpeta `android/` no se versiona

Es código generado que fija versiones de Gradle y del plugin de Android. Versionarla significa que el proyecto deja de compilar dentro de unos meses y que cada actualización de Flutter obliga a un merge manual. Se regenera con `tool/bootstrap.sh`, con la misma versión de Flutter que compila. El script no toca `lib/` ni `pubspec.yaml`.

### La versión de Flutter está fijada

`3.32.0`, tanto en CI como en la documentación. El código usa `Color.withValues(alpha:)`, disponible desde 3.27. Un `latest` flotante rompería la compilación sin aviso.

---

## 5. Seguridad y privacidad

| Aspecto | Estado |
|---|---|
| Datos personales | **Ninguno.** No hay cuentas, correo, nombre ni identificadores |
| Permisos de Android | Ninguno. Sin red, sin cámara, sin almacenamiento externo |
| Telemetría | Ninguna |
| Almacenamiento | Local, en el sandbox de la aplicación; el usuario puede borrarlo desde la propia app |
| Superficie de red | Cero: la aplicación no abre conexiones |

Esta es la postura de privacidad más fuerte posible y no es casual: el usuario es población estudiantil, en parte menor de edad. Cualquier recolección exigiría base legal, consentimiento y responsable de datos. No recolectar nada elimina la categoría entera de problema, y no cuesta ninguna funcionalidad del MVP.

---

## 6. Escalabilidad

| Eje | Preparación actual |
|---|---|
| Más contenido | Agregar una entrada al JSON; la interfaz no cambia. Las opciones del determinador se derivan del catálogo |
| Más módulos | Un `ExerciseModule` nuevo reutiliza todo el motor de práctica |
| Contenido remoto | Cambiar `GeologyLocalDataSource` por uno remoto; dominio e interfaz intactos |
| Más plataformas | iOS y web son un `flutter create --platforms=`; no hay código específico de Android |
| Volumen de progreso | Contenido en `ProgressLocalDataSource` |

**Límite conocido:** `StudentProgress` recalcula competencias y cola de repaso recorriendo la lista completa de intentos. Es correcto y suficiente para el volumen previsto. Con decenas de miles de intentos habría que memoizar, y el lugar natural sería el propio repositorio.

---

## 7. Calidad del código

- `analysis_options.yaml` sobre `flutter_lints`, más `prefer_const_constructors`, `prefer_final_locals`, `avoid_print` y `always_declare_return_types`.
- CI ejecuta `dart format --set-exit-if-changed`, `flutter analyze --fatal-infos` y `flutter test --coverage`.
- Tipos explícitos en declaraciones locales: en una base pensada para que la lea un estudiante, `final List<Mineral> candidates` enseña más que `final candidates`.
- Comentarios que explican **por qué**, no qué. El qué está en el código.

### Evitado a propósito

`CardTheme`, `TabBarTheme` y `DialogTheme` no se usan en el tema: su API cambió entre versiones recientes de Flutter y su uso es una fuente frecuente de roturas al actualizar. Las tarjetas se implementan con un widget propio (`GeoCard`).

---

## 8. Complejidad y riesgo

| Componente | Complejidad | Riesgo |
|---|---|---|
| Catálogo y fichas | Baja | Contenido incorrecto (mitigado con revisión docente y validación en CI) |
| Determinador | **Media-alta** | Es el núcleo; cubierto por pruebas unitarias dedicadas |
| Práctica y progreso | Media | Corrupción de datos persistidos (mitigado con pruebas de ida y vuelta) |
| Casos | Baja | Ninguno relevante |
| Compilación Android | Baja | Desfase de versiones (mitigado fijando Flutter y generando `android/`) |

El componente de mayor riesgo técnico es también el de mayor valor educativo, lo cual es la distribución correcta: donde se concentra el riesgo, se concentra la cobertura de pruebas.
