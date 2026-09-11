# Etapa 1 — Análisis educativo

**Herramienta:** Educational App Factory
**Pregunta rectora:** ¿esta aplicación mejora realmente la forma en que aprende un estudiante?

---

## 1. Problema educativo

El problema declarado en el catálogo maestro es *«dificultad para relacionar teoría geológica con muestras reales»*. Ese enunciado es correcto pero demasiado ancho para diseñar sobre él, así que se descompuso en tres fallas observables y distintas:

| # | Falla concreta | Cómo se manifiesta en el aula |
|---|---|---|
| P1 | **Reconocimiento sin criterio** | El estudiante memoriza el aspecto de la pirita en la foto del PPT, pero ante una muestra real con pátina no sabe qué prueba aplicar. Reconoce, no determina. |
| P2 | **Propiedades como lista, no como árbol de decisión** | Sabe recitar dureza, raya, brillo y clivaje, pero las trata como datos sueltos. No entiende que sirven para *descartar*, ni que unas discriminan más que otras. |
| P3 | **Geología desconectada de la operación** | Identifica correctamente una falla de rumbo en el examen y no relaciona ese dato con que la veta que se está explotando aparece cortada en la labor. |

La aplicación se construye para P1, P2 y P3. No para "enseñar geología".

### Por qué el problema es real

La base de conocimiento académico del proyecto (Ingeniería de Minas) registra entre las dificultades recurrentes de la carrera la visualización 3D a partir de información 2D y la desconexión entre el análisis técnico y la decisión operativa. El laboratorio de mineralogía universitario típico agrava P1: un número limitado de muestras, compartidas, con acceso restringido a horario de práctica, y sin posibilidad de repetir el ejercicio la semana previa al examen.

### Lo que el problema *no* es

No es falta de información. Existen catálogos mineralógicos excelentes, gratuitos y exhaustivos. Si el diagnóstico fuera "el estudiante no tiene dónde consultar propiedades", la aplicación no debería existir: bastaría un enlace a Mindat.

---

## 2. Usuario objetivo

| Dimensión | Definición |
|---|---|
| Carrera | Ingeniería de Minas (secundariamente Geología e Ingeniería Ambiental) |
| Ciclo | III a V — cursos de Mineralogía, Petrología y Geología Minera |
| Conocimiento previo | Conoce la escala de Mohs y los grandes grupos mineralógicos; no ha consolidado el procedimiento de determinación |
| Necesidad específica | Practicar determinación y lectura estructural fuera del horario de laboratorio, con corrección inmediata |
| Contexto de uso | Teléfono de gama media, a menudo sin conexión: laboratorio en sótano, aula, unidad minera en prácticas preprofesionales, transporte |

El contexto de uso es la restricción de diseño más fuerte del proyecto y es la que fuerza la decisión de **funcionamiento totalmente offline**.

### Usuario secundario

El docente de laboratorio, que puede asignar módulos y casos concretos como trabajo previo a la práctica presencial. No se diseña ninguna funcionalidad para él en el MVP, pero la arquitectura de contenido (JSON versionado, independiente del código) deja abierta esa puerta.

---

## 3. Competencia que desarrolla

La competencia central es **determinar muestras geológicas aplicando un procedimiento de descarte y traducir esa determinación a una consecuencia minera**.

Se descompone en cuatro competencias evaluables, que son exactamente las que la aplicación mide:

1. `identificacion_minerales` — aplicar propiedades determinativas para reducir candidatos.
2. `clasificacion_rocas` — clasificar por textura y composición, no por apariencia.
3. `interpretacion_estructuras` — reconocer vetas, fallas y contactos, y anticipar su efecto sobre la continuidad del cuerpo mineralizado.
4. `decision_minera` — elegir el siguiente paso de una campaña con información incompleta (se mide en los casos).

---

## 4. Experiencia de aprendizaje

El modelo es **decidir primero, justificar después**. Todo ejercicio de la aplicación abre con una escena de trabajo, no con una pregunta de examen:

> *Campaña de mapeo superficial, zona de óxidos. Una muestra de color negro-parduzco deja raya rojiza en la porcelana y no responde al imán.*

La aplicación nunca entrega la respuesta antes de que el estudiante se comprometa con una, y siempre entrega la explicación, se haya acertado o no. El error sin explicación no enseña; la explicación sin error previo no se retiene.

---

## 5. Funcionalidades educativas

| Módulo | Qué hace el estudiante | Falla que ataca |
|---|---|---|
| 1. Biblioteca geológica | Consulta fichas con criterios diagnósticos y relevancia minera explícita | P1, P3 |
| 2. Determinador de minerales | Declara lo observado y ve cómo se reduce el conjunto de candidatos; la app le sugiere **cuál es la siguiente prueba más útil** | P2 |
| 3. Clasificación de rocas | Clasifica por textura y composición dentro de escenarios de campo | P1 |
| 4. Explorador de vetas | Reconoce geometrías de mineralización y su implicancia para el método de explotación | P3 |
| 5. Análisis de fallas | Interpreta desplazamientos y su efecto sobre la continuidad de la veta | P3 |
| 6. Casos mineros | Encadena decisiones sobre un mismo yacimiento, con información parcial | P3 |
| 7. Evaluaciones prácticas | Sesiones cortas con repaso dirigido de lo fallado | P1, P2 |

El módulo 2 es el corazón del producto. Es lo único que no puede sustituirse por un PDF, y es lo que se explica en detalle en la Etapa 3.

---

## 6. Impacto esperado

| Indicador | Cómo se mide en la app | Meta de referencia |
|---|---|---|
| Precisión en determinación | `competencyScores` de `identificacion_minerales` | ≥ 80 % con ≥ 5 intentos |
| Reducción de confusiones persistentes | Tamaño de `pendingReviewItemIds` a lo largo del tiempo | Tendencia decreciente |
| Economía de pruebas | Número de criterios declarados hasta resolver en el determinador | Decreciente entre sesiones |
| Transferencia a decisión minera | `competencyScores` de `decision_minera` en casos | ≥ 70 % |

El panel de progreso muestra deliberadamente **métricas de aprendizaje, no de uso**. No hay racha de días, ni tiempo en pantalla, ni número de sesiones. Un estudiante que abre la app cinco días seguidos sin mejorar su precisión no está aprendiendo, y la interfaz no debe felicitarlo por ello.

---

## 7. Diferenciación frente a métodos tradicionales

| Alternativa | Qué ofrece | Qué no ofrece |
|---|---|---|
| PDF / apunte de clase | Las propiedades completas | Descarte interactivo, corrección, medición del propio criterio |
| Catálogo web (Mindat, Webmineral) | Datos mucho más exhaustivos que los nuestros | Enfoque pedagógico, escenario minero, evaluación, funcionamiento offline |
| Video de laboratorio | Ver el procedimiento ejecutado | Ejecutarlo uno mismo y equivocarse |
| Laboratorio presencial | Insustituible: la muestra real | Repetición ilimitada, disponibilidad fuera de horario, corrección inmediata |
| Cuestionario genérico (Kahoot, Forms) | Preguntas y puntaje | El árbol de decisión, el encadenamiento de casos, el repaso dirigido |

**Dónde está realmente la diferenciación:** en el determinador, que no es un buscador con filtros. Un buscador responde "¿qué minerales son metálicos y duros?". El determinador responde *«de las pruebas que aún no hiciste, ¿cuál te conviene hacer ahora?»*. Esa es la habilidad profesional y es la que ninguna alternativa de la tabla entrena.

---

## 8. Veredicto crítico

**La aplicación se aprueba, con tres advertencias que deben quedar registradas.**

### Riesgo 1 — La app no sustituye la muestra real (alto)

Determinar dureza, raya y peso específico requiere la muestra en la mano. La aplicación no puede enseñar a *ejecutar* la prueba, solo a *elegir* qué prueba ejecutar y a interpretar el resultado.

*Mitigación asumida:* se posiciona explícitamente como complemento del laboratorio y el lenguaje de la interfaz refuerza el gesto físico ("frota la muestra sobre porcelana sin vidriar", "sopesa la muestra en la mano"). No se finge un laboratorio virtual que no existe.

### Riesgo 2 — La ilustración esquemática limita el reconocimiento visual (medio)

El MVP no usa fotografías de muestras reales, sino representaciones esquemáticas de color y brillo. Eso entrena el criterio determinativo, no el ojo.

*Mitigación asumida:* se declara como limitación conocida. La fotografía validada por un docente es la primera prioridad de V2, no una función opcional.

### Riesgo 3 — El catálogo es parcial (bajo, pero visible para el usuario)

24 minerales cubren la mineralogía económica peruana relevante, pero 18 de los minerales listados como "confusiones frecuentes" en las fichas no están en el catálogo y aparecen solo como texto, sin enlace. Un estudiante puede notarlo.

*Mitigación asumida:* se documenta y se prioriza en V2. Se prefiere un catálogo corto y correcto a uno extenso y superficial.
