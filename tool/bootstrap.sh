#!/usr/bin/env bash
# Genera las carpetas de plataforma (android/) que no se versionan y deja el
# proyecto listo para compilar.
#
# Por qué android/ no está en el repositorio: es código generado por Flutter y
# contiene versiones fijas de Gradle y del plugin de Android. Versionarlas
# significa que dentro de seis meses el proyecto no compila con un SDK nuevo,
# y que cada actualización de Flutter obliga a un merge manual doloroso.
# Regenerarlas con el mismo Flutter que compila elimina esa clase entera de
# problemas.
#
# A cambio, todo lo que hay que personalizar del proyecto Android (el nombre
# visible y el icono) se aplica aquí, en un solo sitio y de forma repetible.
#
# Uso:
#   bash tool/bootstrap.sh
set -euo pipefail

ORG="pe.edu.geomine"
PROJECT="geomine_explorer"
APP_LABEL="GeoMine Explorer"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: no se encontró 'flutter' en el PATH." >&2
  echo "Instala Flutter 3.32.0 o superior: https://docs.flutter.dev/get-started/install" >&2
  exit 1
fi

echo "==> Flutter detectado:"
flutter --version | head -n 1

if [ -d "$ROOT/android" ]; then
  echo "==> La carpeta android/ ya existe; no se regenera."
else
  SHELL_DIR="$(mktemp -d)"
  trap 'rm -rf "$SHELL_DIR"' EXIT

  echo "==> Generando el proyecto Android en un directorio temporal..."
  flutter create \
    --platforms=android \
    --org "$ORG" \
    --project-name "$PROJECT" \
    "$SHELL_DIR/shell" >/dev/null

  echo "==> Copiando solo android/ al proyecto..."
  cp -r "$SHELL_DIR/shell/android" "$ROOT/android"
fi

# --- Nombre visible -------------------------------------------------------
# `flutter create` usa el nombre del paquete (geomine_explorer) como etiqueta
# del lanzador. El usuario nunca debe ver ese identificador: se sustituye por
# el nombre real de la aplicación. La operación es idempotente.
MANIFEST="$ROOT/android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  echo "==> Ajustando el nombre visible a \"$APP_LABEL\"..."
  TMP_MANIFEST="$(mktemp)"
  sed -E "s/android:label=\"[^\"]*\"/android:label=\"$APP_LABEL\"/" \
    "$MANIFEST" >"$TMP_MANIFEST"
  mv "$TMP_MANIFEST" "$MANIFEST"
  grep -o 'android:label="[^"]*"' "$MANIFEST" || true
fi

echo "==> Descargando dependencias..."
cd "$ROOT"
flutter pub get

# --- Icono ----------------------------------------------------------------
# Se genera aquí y no se versiona por la misma razón que android/: los mipmap
# son artefactos derivados de assets/icon/app_icon.png.
echo "==> Generando el icono de la aplicación..."
dart run flutter_launcher_icons

echo
echo "Listo. Ahora puedes ejecutar:"
echo "  flutter run              # en un dispositivo o emulador"
echo "  flutter test             # pruebas"
echo "  flutter build apk        # APK único de release"
