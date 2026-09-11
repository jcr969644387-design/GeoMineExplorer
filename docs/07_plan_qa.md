# Plan de QA

## Estrategia

La cobertura se concentra donde un fallo enseña algo incorrecto, no donde es fácil escribir pruebas. En orden de prioridad:

1. **Lógica pedagógica** (`domain/usecases`, `domain/entities`) — un error aquí produce enseñanza errónea.
2. **Integridad del contenido** — un dato mal escrito enseña geología falsa y ningún test de UI lo detecta.
3. **Persistencia** — perder el progreso destruye la utilidad del panel de avance.
4. **Flujos de interfaz** — molestan, pero son visibles y recuperables.

---

## Pruebas implementadas

### `test/domain/filter_minerals_test.dart`

| Prueba | Qué protege |
|---|---|
| Valor puntual en el límite de banda | **Regresión documentada.** Con solapamiento estricto, la galena (2,5 exacta) no caía en ninguna banda y una observación correcta devolvía cero candidatos |
| Bandas no solapadas se excluyen | Que el solapamiento inclusivo no vuelva laxo el filtro |
| Brillo particiona en dos mitades disjuntas | Integridad de la primera bifurcación |
| Raya roja resuelve hematita | Caso didáctico central: la raya desmiente al brillo |
| Magnetismo separa magnetita de hematita | El par más confundido del catálogo |
| Densidad descarta livianos | Criterio añadido tras verificar ambigüedades |
| Observaciones contradictorias → conjunto vacío | Que la app no invente un resultado |
| Se sugiere prueba mientras haya ambigüedad | Núcleo pedagógico del determinador |
| No se sugiere prueba ya declarada | Que no pida repetir lo hecho |
| No se sugiere prueba si ya está resuelto | Que no pida trabajo inútil |
| Orden alfabético estable | Que la lista no baile entre renders |

### `test/domain/build_practice_session_test.dart`

Orden por dificultad sin historial; prioridad de lo fallado; un fallo recuperado deja de adelantarse; filtro por módulo; límite de sesión; determinismo ante empates.

### `test/domain/student_progress_test.dart`

Progreso vacío sin división por cero; precisión global; agrupación por competencia; **no declarar dominio con pocos intentos pese a acierto total**; dominio con umbral doble; y tres casos de la cola de repaso, incluido el de intentos que llegan **desordenados** desde el almacenamiento.

### `test/data/geology_mappers_test.dart`

Dureza escrita como entero en el JSON se normaliza a `double`; una clave de brillo desconocida lanza error en lugar de asumir un valor por defecto; los cinco catálogos reales se mapean sin error; cada ejercicio y cada etapa de caso tiene **exactamente una** opción correcta; todas las referencias cruzadas existen.

### `test/data/progress_repository_test.dart`

Primer arranque vacío; acumulación de intentos; **ida y vuelta completa**: el progreso sobrevive a una instancia nueva del repositorio conservando marca de tiempo, fichas revisadas, casos completados y cola de repaso; idempotencia al marcar dos veces la misma ficha; `reset` deja el almacenamiento efectivamente limpio.

### `test/presentation/practice_view_model_test.dart`

Carga de sesión; filtro por módulo; no se confirma sin seleccionar; acierto y error; **no se cambia la respuesta tras confirmar**; **confirmar dos veces no duplica el marcador**; `next` no avanza sin confirmar; limpieza de selección al avanzar; sesión completa hasta el resumen; y un fallo de lectura de contenido se expone como estado de error en lugar de propagar la excepción.

### `test/presentation/identification_view_model_test.dart`

Estado inicial; conteo de criterios; **`null` borra la observación en lugar de ignorarse** (el riesgo clásico de `copyWith`); borrar una observación no arrastra a las demás; `reset`; `copyWith` conserva lo no tocado.

### `test/presentation/app_widget_test.dart`

Pruebas de integración sobre la aplicación completa, con el catálogo real cargado desde disco y almacenamiento en memoria: arranque y listado; búsqueda por nombre y por fórmula; estado vacío; apertura y cierre de ficha; pestañas de rocas y estructuras; reducción de candidatos en el determinador; **resolución de la hematita por su raya**; botón de limpiar; sesión de práctica con confirmación y explicación; selección de módulo; registro del intento en el avance; apertura de un caso; panel de avance en cero.

---

## Validación de contenido: `tool/validate_content.py`

Se ejecuta en CI como trabajo independiente. Verifica:

- JSON válido e identificadores únicos en las cinco colecciones.
- Brillo, clivaje, tipo de roca y módulo dentro de los valores admitidos.
- Dureza dentro de la escala de Mohs y con `min ≤ max`; peso específico plausible; color en formato `#RRGGBB`.
- Presencia de criterios diagnósticos, relevancia minera, claves de identificación e implicancia minera.
- **Ninguna banda de dureza o densidad vacía**, o el determinador ofrecería opciones que nunca devuelven resultados.
- Exactamente una alternativa correcta por ejercicio y por etapa de caso; mínimo dos alternativas; sin ids duplicados.
- Toda referencia cruzada existente.
- Al menos 4 ejercicios por módulo.

Emite advertencias no bloqueantes por los 18 minerales citados como confusión que aún no tienen ficha propia (limitación conocida del MVP, ver `docs/04_mvp.md`).

---

## Ejecución

```bash
flutter test                      # todas las pruebas
flutter test --coverage           # con reporte lcov
flutter test test/domain          # solo lógica pedagógica
python tool/validate_content.py   # integridad del contenido
```

---

## Lo que no está cubierto, y por qué

| Sin cubrir | Motivo |
|---|---|
| Pruebas de integración en dispositivo real | Requieren emulador en CI; el valor marginal sobre los widget tests no lo justifica en el MVP |
| Pruebas de rendimiento | El contenido está cacheado y es pequeño; sin señal de problema |
| Corrección geológica del contenido | **No es automatizable.** Exige revisión de un docente de Mineralogía, declarada como requisito de liberación en `docs/04_mvp.md` |
| Accesibilidad con lector de pantalla | Limitación reconocida; pendiente para V2 |
