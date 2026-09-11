#!/usr/bin/env bash
# Genera las carpetas de plataforma (android/) que no se versionan.
#
# Por qué no están en el repositorio: son código generado por Flutter y
# contienen versiones fijas de Gradle y del plugin de Android. Versionarlas
# significa que dentro de seis meses el proyecto no compila con un SDK nuevo,
# y que cada actualización de Flutter obliga a un merge manual doloroso.
# Regenerarlas con el mismo Flutter que compila elimina esa clase entera de
# problemas.
#
# Uso:
#   bash tool/bootstrap.sh
set -euo pipefail

ORG="pe.edu.geomine"
PROJECT="geomine_explorer"
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

echo "==> Descargando dependencias..."
cd "$ROOT"
flutter pub get

echo
echo "Listo. Ahora puedes ejecutar:"
echo "  flutter run              # en un dispositivo o emulador"
echo "  flutter test             # pruebas"
echo "  flutter build apk        # APK de release"
