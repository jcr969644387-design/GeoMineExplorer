# Etapa 2 — Validación académica

**Herramienta:** Engineering & Academic Knowledge Base
**Pregunta rectora:** ¿la aplicación representa correctamente la disciplina que enseña?

---

## 1. Cursos relacionados

| Curso | Ciclo típico | Aporte de la aplicación |
|---|---|---|
| Mineralogía | III | Módulos 1, 2 y 7 — determinación sistemática |
| Petrología / Petrografía | IV | Módulo 3 — clasificación por textura y composición |
| Geología Estructural | IV | Módulos 4 y 5 — vetas, fallas, pliegues |
| Geología Minera / Yacimientos | V | Módulo 6 — casos, zonación, controles de mineralización |
| Exploración Minera | V–VI | Módulo 6 — decisiones de campaña con información incompleta |

---

## 2. Conceptos fundamentales representados

### Propiedades determinativas

La clave implementada usa siete criterios, en el orden en que se aplican en campo:

1. **Brillo** (metálico / no metálico) — primera bifurcación clásica de toda clave determinativa.
2. **Dureza**, expresada como banda de rayado y no como número de Mohs.
3. **Color de raya** — el criterio más estable, porque no depende de la pátina.
4. **Peso específico**, como prueba de sopesar en la mano.
5. **Clivaje** (ausente / regular / perfecto).
6. **Magnetismo**.
7. **Reacción con HCl diluido en frío**.

**Decisión de fidelidad disciplinar deliberada:** la dureza no se pide como número. Nadie determina "dureza 3,5" en una labor. Se pide como prueba de rayado —uña, moneda de cobre, punta de acero, vidrio—, que es exactamente el procedimiento real y el que produce las bandas del enum `HardnessBand`.

**Corolario técnico de esa decisión:** las bandas se solapan de forma inclusiva en los límites. Un mineral de dureza 2,5 exacta, como la galena, es genuinamente ambiguo frente a la prueba de la moneda de cobre y debe aparecer en ambas bandas. Excluirlo por un límite cerrado haría que una observación *correcta* del estudiante devolviera cero candidatos: un error de software que además enseñaría algo falso sobre la naturaleza de la prueba. Hay una prueba unitaria dedicada a este caso.

### Mineralogía económica

El catálogo prioriza la asociación mineralógica peruana real antes que la representatividad mineralógica general:

- **Sulfuros de Cu:** calcopirita, bornita, calcosina, covelina, enargita.
- **Sulfuros de Pb-Zn-Ag:** galena, esfalerita.
- **Sulfuros de Fe:** pirita, pirrotita, arsenopirita, marcasita (esta última solo como confusión).
- **Molibdeno:** molibdenita.
- **Óxidos de Fe:** hematita, magnetita.
- **Zona de oxidación:** malaquita.
- **Ganga y alteración:** cuarzo, calcita, baritina, yeso, fluorita, feldespato, moscovita, biotita, rodocrosita.

La rodocrosita se incluye por su relevancia local (Uchucchacua) y la enargita por su papel determinante en las penalidades por arsénico en concentrados peruanos, un dato que los estudiantes suelen encontrar por primera vez ya en planta.

### Estructuras y control de la mineralización

Las 12 estructuras cubren tres familias con implicancia operativa distinta:

- **Geometrías de mineralización:** veta tabular, vetas ramificadas, stockwork, diseminado, brecha hidrotermal. Determinan el método de explotación viable.
- **Estructuras de desplazamiento:** falla normal, inversa, de rumbo. Determinan la continuidad del cuerpo.
- **Contactos y pliegues:** contacto intrusivo, anticlinal, sinclinal, diaclasa.

Cada ficha declara explícitamente el campo `miningImplication`, porque ese es justamente el salto que la falla P3 del análisis educativo identifica como ausente.

---

## 3. Competencias profesionales

La aplicación se alinea con competencias reconocibles del perfil de egreso del ingeniero de minas:

| Competencia profesional | Evidencia dentro de la app |
|---|---|
| Caracterizar geológicamente un yacimiento | Módulos 1–5 |
| Aplicar criterio técnico con información incompleta | Determinador y casos |
| Anticipar el efecto de la geología sobre la operación | Campo `miningImplication` y casos |
| Comunicar una decisión técnica fundamentada | Explicaciones que exigen justificar, no solo acertar |

---

## 4. Dificultades comunes atendidas

| Dificultad documentada en la carrera | Respuesta de la aplicación |
|---|---|
| Visualizar en 3D a partir de información 2D | Parcial: los casos describen relaciones espaciales en texto. **Es la debilidad académica principal del MVP.** |
| Tratar criterios técnicos como fórmulas en lugar de juicios | El determinador muestra un *conjunto* de candidatos, nunca una respuesta única automática |
| Desconexión entre análisis técnico y decisión operativa | Todo ejercicio abre con escena profesional; los casos encadenan consecuencias |
| Confundir minerales de aspecto similar | Campo `confusedWith` + cola de repaso dirigido sobre lo fallado |

---

## 5. Aplicaciones prácticas representadas

Los tres casos reproducen situaciones de campaña reconocibles:

1. **La veta que desapareció** — una falla de rumbo desplaza el cuerpo; la decisión es dónde y en qué sentido buscar la prolongación. Es el error de campo más caro y más frecuente del repertorio.
2. **Leer un sondaje de pórfido** — zonación vertical de alteración y sulfuros; la decisión es qué tramo ensayar primero con presupuesto limitado.
3. **Dónde poner la plataforma** — skarn de contacto; la decisión es ubicar perforaciones a partir del control estructural, no del afloramiento más visible.

---

## 6. Veredicto de validación académica

**La aplicación representa correctamente la disciplina, con dos reservas explícitas.**

### Reserva 1 — El determinador no puede resolver todos los pares (aceptada y tratada)

Se verificó computacionalmente que, declarando las siete propiedades correctamente, 21 de los 24 minerales quedan resueltos a un solo candidato. Los tres pares que no se resuelven son:

| Par | Qué los separa realmente |
|---|---|
| bornita / calcosina | Color fresco y pátina de alteración |
| baritina / fluorita | Clivaje octaédrico y color |
| yeso / moscovita | Elasticidad de la lámina (la mica se dobla y recupera; el yeso no) |

Esto **no es un defecto**: es la verdad disciplinar. Ninguna clave macroscópica de siete criterios resuelve el universo mineral completo, y pretender lo contrario enseñaría algo falso. El tratamiento adoptado es que los tres pares están declarados recíprocamente en el campo `confusedWith` de ambas fichas, de modo que cuando la clave se detiene, la ficha continúa con el criterio que sí los separa. El texto de la interfaz se corrigió para decir exactamente eso, en lugar de sugerir erróneamente que haría falta análisis instrumental.

### Reserva 2 — La visualización espacial queda pendiente (limitación reconocida del MVP)

La dificultad mejor documentada de la carrera —pasar de 2D a 3D— se atiende solo parcialmente con texto. Resolverla bien exige esquemas de bloque diagramados, y con rigor, corte 3D interactivo. Eso está deliberadamente fuera del MVP (ver Etapa 4) y es la prioridad académica de V2.
