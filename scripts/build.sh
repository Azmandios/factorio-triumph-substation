#!/usr/bin/env bash
# Собирает zip мода для Mod Portal: dist/<name>_<version>.zip
# Внутри zip лежит папка <name>_<version>, как ожидает Factorio.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

NAME="$(python3 -c 'import json; print(json.load(open("info.json"))["name"])')"
VERSION="$(python3 -c 'import json; print(json.load(open("info.json"))["version"])')"

DIST="$ROOT/dist"
STAGE="$DIST/${NAME}_${VERSION}"
ARCHIVE="$DIST/${NAME}_${VERSION}.zip"

# Файлы и папки, которые попадают в релиз.
ENTRIES=(info.json changelog.txt control.lua data.lua graphics locale migrations prototypes)
OPTIONAL=(README.md LICENSE)

rm -rf "$STAGE" "$ARCHIVE"
mkdir -p "$STAGE"

for entry in "${ENTRIES[@]}"; do
  if [ ! -e "$ROOT/$entry" ]; then
    echo "Не найден обязательный элемент: $entry" >&2
    exit 1
  fi
  cp -R "$ROOT/$entry" "$STAGE/"
done

for entry in "${OPTIONAL[@]}"; do
  if [ -e "$ROOT/$entry" ]; then
    cp -R "$ROOT/$entry" "$STAGE/"
  fi
done

# Служебный мусор не должен попадать в архив.
find "$STAGE" -name '.DS_Store' -delete

(cd "$DIST" && zip -qr "$(basename "$ARCHIVE")" "$(basename "$STAGE")")

echo "Собрано: $ARCHIVE"
