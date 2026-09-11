# Cómo contribuir

Hay dos tipos de contribución con criterios distintos: **contenido geológico** y **código**.

---

## Contenido geológico

El contenido vive en `assets/data/` como JSON, a propósito: un docente puede revisarlo y corregirlo sin saber Dart.

### Antes de proponer un cambio

```bash
python tool/validate_content.py
```

Debe terminar con `Contenido válido.`

### Reglas

1. **Cada ejercicio tiene exactamente una alternativa correcta.** Validado automáticamente.
2. **Todo ejercicio abre con una escena profesional** (campo `context`). Una pregunta descontextualizada no pertenece a esta aplicación.
3. **Toda ficha declara su relevancia minera.** Si un mineral no tiene consecuencia en una operación, probablemente no corresponde al catálogo.
4. **La explicación explica el razonamiento, no repite la respuesta.** «Es galena» no es una explicación; «el clivaje cúbico perfecto y el peso descartan la esfalerita» sí lo es.
5. **Un mineral nuevo debe caber en alguna banda de dureza y de densidad.** Validado automáticamente.
6. **Las referencias cruzadas deben existir.** Validado automáticamente.

Los cambios de contenido van en ramas `content/*` y requieren revisión de alguien con formación geológica. La revisión de código y la revisión geológica son actividades distintas, hechas por personas distintas.

---

## Código

### Antes de proponer un cambio

```bash
dart format lib test
flutter analyze --fatal-infos
flutter test
```

Los tres deben pasar. CI los ejecuta igualmente.

### Reglas de arquitectura

1. **`domain/` no importa Flutter.** Ni `material.dart`, ni `widgets.dart`, ni `flutter_riverpod`. Es lo que permite probar la lógica pedagógica sin binding de widgets.
2. **Las vistas no contienen lógica de negocio.** Si una vista calcula algo sobre el contenido, ese cálculo pertenece a un caso de uso.
3. **Los ViewModels reciben dependencias por constructor.** Nunca construyen repositorios ni leen providers directamente.
4. **La lógica pedagógica va en `domain/usecases`.** Si es una regla sobre cómo se aprende, no es un detalle de interfaz.
5. **Toda dependencia nueva se justifica en el pull request.** Hoy hay dos. Cada paquete añadido es mantenimiento permanente.

### Estilo

- Tipos explícitos en declaraciones locales: `final List<Mineral> candidates`, no `final candidates`. Esta base de código la leen estudiantes.
- Los comentarios explican **por qué**, no qué. El qué está en el código.
- Sin `print`. Está prohibido por el linter.

### Pruebas

Un cambio en `domain/` **necesita** prueba. Es donde un error enseña algo incorrecto, y es la parte más barata de probar.

Los cambios de interfaz necesitan prueba si alteran un flujo que ya está cubierto en `test/presentation/app_widget_test.dart`.

---

## Qué no se acepta

| Propuesta | Motivo |
|---|---|
| Rachas, insignias, puntos, clasificaciones | Miden constancia, no criterio. Ver `docs/03_diseno_ux.md` |
| Funciones que requieran conexión | Rompen el uso en laboratorio y en unidad minera |
| Recolección de datos personales | Ver la sección de privacidad del README |
| IA que determine el mineral por el estudiante | Sustituye la habilidad que la app existe para formar. Ver `docs/06_ia.md` |
| Versionar la carpeta `android/` | Ver `docs/08_devops.md` |

Ninguna es una prohibición arbitraria: cada una tiene su razón documentada. Si se propone revisar alguna, el pull request debería discutir esa razón.
