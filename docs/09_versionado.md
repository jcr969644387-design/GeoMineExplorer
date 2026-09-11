# Versionado y entregas

## Regla

Cada corrección publicada incrementa el **último dígito** de la versión, de forma consecutiva:

```
GeoMineExplorerV1.0.1
GeoMineExplorerV1.0.2
GeoMineExplorerV1.0.3
...
```

No hay versiones intermedias, ni sufijos (`-beta`, `-rc`), ni saltos. Si una entrega se descarta, su número no se reutiliza: se pasa al siguiente.

## Los cuatro sitios que deben coincidir

Una entrega `GeoMineExplorerV1.0.X` obliga a tocar exactamente estos cuatro puntos, y los cuatro deben decir lo mismo:

| Dónde | Qué se escribe | Ejemplo |
|---|---|---|
| `pubspec.yaml` → `version:` | `1.0.X+N` | `1.0.1+2` |
| `lib/app/app_info.dart` → `AppInfo.version` | `1.0.X` | `1.0.1` |
| Mensaje del commit | `GeoMineExplorerV1.0.X` | `GeoMineExplorerV1.0.1` |
| APK publicado | `GeoMineExplorerV1.0.X.apk` | `GeoMineExplorerV1.0.1.apk` |

El nombre del APK **no se escribe a mano**: el flujo de compilación lo deriva de `pubspec.yaml`, de modo que es imposible publicar un archivo cuyo nombre no corresponda a la versión compilada.

El número tras el `+` (`+2`) es el *build number* de Android. Sube de uno en uno en cada entrega y nunca baja: Android se niega a instalar una actualización con un build number menor que el instalado.

## Un commit por versión

Cada entrega es **un único commit**, cuyo mensaje es exactamente la etiqueta de la versión y nada más:

```
GeoMineExplorerV1.0.1
```

Sin punto final, sin descripción en la primera línea, sin dos commits con el mismo nombre. La razón es práctica: el historial se lee como una lista de entregas, y `git log --oneline` es directamente el changelog de versiones.

El detalle de qué cambió en cada una vive en [`../CHANGELOG.md`](../CHANGELOG.md), no en el mensaje del commit.

## Procedimiento de una entrega

1. Hacer los cambios en el árbol de trabajo.
2. Subir la versión en `pubspec.yaml` (`1.0.X+N`) y en `lib/app/app_info.dart`.
3. Añadir la entrada correspondiente en `CHANGELOG.md`.
4. Un solo commit:

   ```bash
   git add -A
   git commit -m "GeoMineExplorerV1.0.X"
   git push origin main
   ```

5. Opcionalmente, etiquetar para generar una release con el APK adjunto:

   ```bash
   git tag v1.0.X
   git push origin v1.0.X
   ```

Si hace falta corregir algo ya commiteado **antes de publicar**, se usa `git commit --amend` en lugar de crear un segundo commit: así sigue habiendo exactamente uno por versión.

## Cuándo cambiar el segundo o el primer dígito

La regla del dígito final cubre las correcciones. Los otros dos se reservan para cambios de otra naturaleza, y se decidirán explícitamente cuando ocurran:

| Cambio | Ejemplo |
|---|---|
| `1.0.X` — corrección o ajuste | arreglar el APK, rediseñar una pantalla, ampliar contenido |
| `1.X.0` — módulo nuevo completo | catálogo fotográfico, modo examen, sincronización |
| `X.0.0` — cambio de alcance del producto | pasar de asignatura a plan de carrera completo |
