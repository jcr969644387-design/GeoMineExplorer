# Etapa 3 — Diseño de experiencia educativa

**Herramienta:** Educational UX Designer
**Pregunta rectora:** ¿la experiencia dentro de la aplicación facilita el aprendizaje?

---

## 1. Flujo de aprendizaje

La navegación es **plana: cinco destinos, sin jerarquía**.

```
Catálogo  ·  Determinar  ·  Práctica  ·  Casos  ·  Avance
```

La razón es contextual: el estudiante abre esta aplicación con una muestra en la mano, de pie, en medio de una práctica de laboratorio. Cada nivel de jerarquía es tiempo que no tiene. Un menú de secciones anidadas sería más ordenado sobre el papel y peor en la mesa de laboratorio.

Los cinco destinos corresponden a cuatro intenciones distintas, deliberadamente no mezcladas:

| Destino | Intención del estudiante | Modo |
|---|---|---|
| Catálogo | «Tengo una duda puntual» | Consulta |
| Determinar | «Tengo una muestra y no sé qué es» | Procedimiento |
| Práctica | «Quiero entrenar» | Evaluación formativa |
| Casos | «Quiero aplicar» | Decisión encadenada |
| Avance | «¿Estoy mejorando?» | Metacognición |

Solo **Catálogo** es lectura pasiva. Los otros cuatro exigen que el estudiante se comprometa con una respuesta.

---

## 2. Interacción: el determinador

Es el núcleo del producto y merece justificar cada decisión.

### No es un filtro de búsqueda

Un filtro devuelve resultados. El determinador devuelve **resultados más una recomendación de qué hacer a continuación**:

> *5 candidatos. Siguiente prueba más útil: color de raya.*

El algoritmo (`FilterMinerals._bestNextTest`) elige, entre las propiedades aún no observadas, la que produce la partición más equilibrada del conjunto actual de candidatos: mayor número de grupos distintos y, a igualdad, el grupo más grande lo más pequeño posible.

**Por qué importa pedagógicamente:** el estudiante novato aplica todas las pruebas mecánicamente, en el orden en que aparecen en su apunte. El geólogo experimentado aplica dos o tres, elegidas. Esa economía de pruebas es la habilidad real, y es invisible en cualquier material estático. Aquí se hace explícita y se practica.

### Funciona con información parcial

Todos los criterios son opcionales. En campo casi nunca se dispone de todos —no siempre hay imán, ni ácido, ni porcelana— y una clave que exija completarlos todos sería una ficción. El contador de candidatos se actualiza con cada observación declarada.

### Nunca afirma más de lo que sabe

Si quedan tres candidatos, muestra tres. No elige uno "más probable". La tentación de mostrar un resultado único es fuerte y sería exactamente el error que el análisis académico identifica: tratar el criterio técnico como fórmula en lugar de como juicio.

Cuando las pruebas se agotan y aún quedan candidatos, el texto remite a los criterios diagnósticos de las fichas, que es lo que un docente diría.

---

## 3. Práctica

- **Sesiones de ocho ejercicios.** Corta a propósito: una sesión que se completa entre clases en lugar de un cuestionario largo que se abandona a la mitad.
- **Escena antes del enunciado.** Cada ejercicio abre con el contexto de trabajo. El estudiante decide *dentro de una situación*, no responde una pregunta descontextualizada.
- **Confirmación explícita.** Elegir no es responder; hay un paso de confirmación. Esto elimina el toque accidental y, más importante, obliga a un momento de compromiso con la respuesta.
- **Explicación siempre.** Se acierte o se falle. Al acertar se lee por qué el razonamiento fue correcto —que no es lo mismo que haber acertado por suerte.
- **Se marca lo elegido y lo correcto.** Ver el propio error junto a la respuesta correcta es lo que convierte el fallo en aprendizaje.

### Repaso dirigido

El orden de la sesión no es aleatorio (`BuildPracticeSession`):

1. Ejercicios fallados y **aún no recuperados**.
2. Ejercicios nunca intentados, de menor a mayor dificultad.
3. Ejercicios ya acertados, para consolidar.

El problema educativo declarado es la confusión persistente entre minerales parecidos. Reencontrar justamente lo que se falló es lo que corrige esa confusión; un orden aleatorio la dejaría intacta.

---

## 4. Casos

Los casos son decisiones **encadenadas sobre un mismo yacimiento**. La diferencia con la práctica no es la dificultad, es la estructura: cada etapa entrega información nueva de campo y el estudiante decide con lo que tiene, sin poder retroceder.

Es la única parte de la aplicación donde se experimenta algo que un cuestionario no puede dar: que una decisión temprana condiciona lo que se puede hacer después.

---

## 5. Evaluación y progreso

El panel de avance muestra, por competencia, intentos y precisión; e indica dominio solo con **al menos 5 intentos y 80 % de acierto**. El umbral es doble a propósito: un solo acierto no es dominio, y declararlo así sería mentirle al estudiante sobre su preparación antes de un examen.

**Lo que el panel deliberadamente no muestra:**

- Rachas de días consecutivos.
- Tiempo total en la aplicación.
- Insignias, niveles, puntos o clasificaciones.

Las reglas de trabajo del proyecto exigen justificar toda gamificación por el problema que resuelve. Aquí no resuelve ninguno: mide constancia, no criterio. Un estudiante con racha de doce días y 45 % de precisión recibiría una felicitación falsa. Lo único que se muestra es evidencia de aprendizaje.

La única mecánica de refuerzo presente es la cola de repaso, que es instruccional y no motivacional.

---

## 6. Personalización

Toda la personalización del MVP es **implícita y derivada del desempeño**: qué ejercicios aparecen primero, qué prueba se sugiere a continuación, qué competencias se señalan como no consolidadas. No hay configuración de perfil, ni selección de nivel, ni onboarding con preguntas. El sistema se adapta por lo que el estudiante hace, no por lo que declara.

---

## 7. Diseño móvil

| Decisión | Motivo |
|---|---|
| **Offline total** | El laboratorio suele estar en sótano; la unidad minera no tiene cobertura. Una app que falla ahí, falla cuando más se necesita. |
| **Paleta anclada al dominio** | Malaquita (acción), pirita (atención), hematita (error), grafito y gris mineral frío. Los colores provienen de los minerales que la app enseña, no de una plantilla. |
| **Tema claro y oscuro** | El laboratorio con lámpara y el estudio nocturno son contextos reales de uso. |
| **Sin fuentes externas** | Cargar tipografías de red contradice el requisito offline y añade peso sin beneficio educativo. |
| **Muestra esquemática, no foto** | Preferimos un esquema honesto de color y brillo antes que una foto de banco de imágenes sin validar. Una foto incorrecta enseña algo falso; el esquema no pretende ser la muestra. |
| **Buscador siempre visible** | En el catálogo se viene a resolver una duda concreta; esconderlo tras un icono cuesta un toque en el peor momento. |

### Limitación de accesibilidad reconocida

La muestra esquemática usa color como portador de información. Para un estudiante con discromatopsia esa señal se pierde. Se mitiga parcialmente porque **toda** propiedad relevante aparece también como texto en la ficha, pero la muestra visual sigue siendo menos útil para ese usuario. Corresponde tratarlo en V2 junto con la incorporación de fotografía.
