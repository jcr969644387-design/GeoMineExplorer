# Etapa 4 — Definición del MVP

**Herramienta:** MVP Builder
**Pregunta rectora:** ¿cuál es la versión más pequeña que ya genera valor educativo?

---

## 1. Funcionalidad principal

**Determinar una muestra mineral mediante descarte sistemático, y comprobar si el criterio propio mejora.**

Si la aplicación hiciera solo esto, ya resolvería la falla P2 del análisis educativo y ya sería mejor que cualquier PDF. Todo lo demás se justifica por sostener o extender esa función.

---

## 2. Alcance del MVP

| Módulo del encargo | Estado | Justificación |
|---|---|---|
| 1. Biblioteca geológica | **En el MVP** | El determinador no sirve sin fichas a las que remitir |
| 2. Identificación de minerales | **En el MVP** | Es la funcionalidad principal |
| 3. Clasificación de rocas | **En el MVP** | Segunda competencia declarada; mismo motor de ejercicios |
| 7. Evaluaciones prácticas | **En el MVP** | Sin medición no hay evidencia de aprendizaje ni repaso dirigido |
| Panel de avance | **En el MVP** | Es lo que convierte la práctica en metacognición |
| 4. Explorador de vetas | **Incluido, fuera del alcance mínimo** | Ver nota de transparencia |
| 5. Análisis de fallas | **Incluido, fuera del alcance mínimo** | Ver nota de transparencia |
| 6. Casos mineros reales | **Incluido, fuera del alcance mínimo** | Ver nota de transparencia |

### Nota de transparencia sobre los módulos 4, 5 y 6

El alcance mínimo recomendado eran los módulos 1, 2, 3 y 7. Los módulos 4, 5 y 6 **se implementaron igualmente**, y corresponde decir con claridad por qué, para no confundir "alcance disciplinado" con "todo cabe":

Los tres son **puramente dirigidos por datos**. Vetas y fallas son fichas de catálogo que reutilizan exactamente la misma pantalla de detalle que minerales y rocas. Los casos reutilizan el mismo componente de alternativa y explicación que la práctica, con un contador de etapas. Ninguno introdujo una pantalla nueva de arquitectura propia, una dependencia nueva ni un modelo de datos nuevo. El costo técnico marginal fue cercano a cero y el riesgo añadido, mínimo.

**Esto no es una licencia general.** Un módulo se incorpora fuera del alcance mínimo únicamente si cumple las tres condiciones: reutiliza componentes existentes, no añade dependencias y no añade estado nuevo. La visión artificial, el 3D y la sincronización no cumplen ninguna de las tres, y por eso están fuera.

---

## 3. Fuera del MVP, y por qué

| Excluido | Motivo |
|---|---|
| **Reconocimiento de minerales por foto** | Requiere miles de imágenes etiquetadas y validadas por un especialista. Sin ese dataset, un modelo genérico acertaría poco y con seguridad aparente: enseñaría errores con confianza. Excluido por el análisis de IA (Etapa 6). |
| **Modelos 3D interactivos de yacimientos** | Es la mejor respuesta a la dificultad académica más documentada, y es costoso: modelado, rendimiento en gama media, peso del paquete. Merece una versión propia, no un rincón del MVP. |
| **Cuentas de usuario y sincronización** | Añade backend, autenticación, privacidad de datos de menores de edad y costo operativo permanente, sin mejorar lo que el estudiante aprende. |
| **Modo docente y asignación de tareas** | Valioso, pero requiere validación previa con estudiantes. Diseñarlo antes de saber si el producto funciona es construir sobre una suposición. |
| **Contenido descargable / catálogos remotos** | El repositorio ya está preparado (Repository Pattern), pero activarlo exige infraestructura que el MVP no necesita. |
| **Ranking y competencia entre estudiantes** | Mide velocidad y constancia, no criterio. Contradice el criterio 7 de calidad del proyecto. |

---

## 4. Contenido mínimo del MVP

| Colección | Cantidad |
|---|---|
| Minerales | 24 |
| Rocas | 16 |
| Estructuras | 12 |
| Ejercicios situacionales | 24 |
| Casos encadenados | 3 (13 decisiones) |

El criterio no fue la cantidad sino la cobertura: cada banda de dureza y cada banda de densidad debe contener al menos un mineral, y cada módulo de práctica debe tener ejercicios suficientes para una sesión. Ambas condiciones se verifican automáticamente en integración continua (`tool/validate_content.py`).

---

## 5. Método de validación

### Antes de liberar

- CI en verde: formato, análisis estático, pruebas, validación de contenido.
- Revisión del catálogo por un docente de Mineralogía. **No opcional:** un dato erróneo en una ficha enseña algo falso, y ningún test automático puede detectarlo.

### Piloto (4 semanas, un curso de Mineralogía)

| Pregunta | Evidencia |
|---|---|
| ¿Se usa fuera del horario de laboratorio? | Distribución horaria de intentos |
| ¿Mejora la precisión? | `competencyScores` entre semana 1 y semana 4 |
| ¿Disminuye la cola de repaso? | Tamaño de `pendingReviewItemIds` en el tiempo |
| ¿Baja el número de pruebas hasta resolver? | Criterios declarados por determinación |
| ¿Transfiere al laboratorio real? | Contraste con la evaluación presencial del curso |

### Criterio de fracaso, declarado por adelantado

Si tras el piloto la precisión en `identificacion_minerales` no mejora de forma apreciable, **el problema no es de contenido ni de interfaz: es del supuesto central del producto**, y corresponde revisar el diagnóstico antes de construir V2. Declararlo ahora evita la tentación posterior de atribuir el resultado a "falta de contenido" y responder agregando minerales.

---

## 6. Hoja de ruta posterior

**V2 — corregir las limitaciones conocidas**
1. Fotografía de muestras validada por un docente.
2. Esquemas de bloque para relaciones espaciales (atiende la dificultad 2D→3D).
3. Ampliación del catálogo a los 18 minerales hoy citados como confusión sin ficha propia.
4. Accesibilidad: reducir la dependencia del color como portador de información.

**V3 — evaluar con datos de uso reales**
5. Asistente de explicación con IA, acotado al catálogo (ver Etapa 6).
6. Modo docente.
7. Sincronización, si y solo si el modo docente la exige.

**V4 — solo con dataset propio**
8. Reconocimiento visual de minerales.
