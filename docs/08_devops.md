# DevOps y entrega

## Flujos de integración continua

### `.github/workflows/ci.yml`

Se ejecuta en cada `push` y `pull request` sobre `main` y `develop`.

| Trabajo | Pasos |
|---|---|
| `analyze-and-test` | Formato (`dart format --set-exit-if-changed`), análisis estático (`flutter analyze --fatal-infos`), pruebas con cobertura, publicación del reporte lcov |
| `validate-content` | `python tool/validate_content.py` |

La validación de contenido es un trabajo separado a propósito: no necesita Flutter, corre en segundos y falla con un mensaje que un revisor no programador puede entender.

### `.github/workflows/build-apk.yml`

Se ejecuta en `push` a `main`, en etiquetas `v*` y manualmente.

1. Java 17 y Flutter 3.32.0.
2. `flutter pub get`.
3. **`bash tool/bootstrap.sh`** — genera la carpeta `android/`.
4. `flutter build apk --release --split-per-abi` y APK universal.
5. Publica los APK como artefacto (30 días).
6. Si el disparador fue una etiqueta `v*`, los adjunta a la release de GitHub.

---

## Por qué `android/` no está en el repositorio

Es código generado por Flutter que fija versiones concretas de Gradle y del plugin de Android. Versionarlo tiene dos consecuencias conocidas: el proyecto deja de compilar cuando el entorno se actualiza, y cada actualización de Flutter obliga a un merge manual de archivos que nadie escribió a mano.

`tool/bootstrap.sh` genera un proyecto de plataforma en un directorio temporal con la **misma versión de Flutter que va a compilar**, y copia únicamente la carpeta `android/`. Nunca toca `lib/`, `pubspec.yaml` ni los assets. El mismo script se usa en local y en CI, de modo que no hay dos procedimientos distintos que puedan divergir.

---

## Puesta en marcha local

```bash
git clone <url-del-repositorio>
cd geomine_explorer
bash tool/bootstrap.sh    # genera android/ y descarga dependencias
flutter run
```

**Requisito:** Flutter 3.32.0 o superior. El código usa `Color.withValues(alpha:)`, disponible desde 3.27; una versión anterior no compila.

---

## Generar el APK sin entorno local

1. Crear un repositorio en GitHub y subir el contenido de este paquete.
2. Entrar en **Actions**, seleccionar **Build APK** y pulsar **Run workflow**.
3. Al terminar, descargar el artefacto `geomine-explorer-apk`.

Contiene el APK universal y los APK por arquitectura (`armeabi-v7a`, `arm64-v8a`, `x86_64`). Para instalar en un teléfono cualquiera, el universal es el más simple; los separados pesan menos.

---

## Publicar una versión

```bash
git tag v1.0.0
git push origin v1.0.0
```

Dispara la compilación y adjunta los APK a la release de GitHub.

---

## Firma de la aplicación

El MVP compila con la clave de depuración de Flutter, suficiente para distribución interna y pruebas piloto.

Para publicar en Google Play hace falta firma propia:

1. Generar un keystore con `keytool`.
2. Cargarlo en GitHub como secreto (base64) junto con las contraseñas.
3. Añadir un paso al flujo que lo restaure y escriba `android/key.properties` antes de compilar.
4. **Nunca** versionar el keystore ni las contraseñas.

No se incluye configurado porque requiere credenciales que deben generarse en la institución, no en el repositorio.

---

## Ramas sugeridas

| Rama | Uso |
|---|---|
| `main` | Estable; dispara la compilación del APK |
| `develop` | Integración |
| `feature/*` | Trabajo en curso, vía pull request |
| `content/*` | Cambios de catálogo revisados por un docente |

La rama `content/*` existe por un motivo concreto: la revisión geológica y la revisión de código son actividades distintas, hechas por personas distintas, y conviene que no se bloqueen entre sí.
