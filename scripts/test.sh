#!/usr/bin/env bash
# Полная проверка мода: статические проверки, сборка, дамп прототипов и
# headless-сценарный тест атомного взрыва в Factorio.
#
# Переменные окружения:
#   FACTORIO_BIN    путь к бинарнику Factorio
#   FACTORIO_MODS   каталог модов Factorio (нужен для config.ini)
#
# Если бинарник Factorio не найден — проверка пропускается (exit 0).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FACTORIO_MODS="${FACTORIO_MODS:-$HOME/Library/Application Support/factorio/mods}"
FACTORIO_BIN="${FACTORIO_BIN:-$HOME/Library/Application Support/Steam/steamapps/common/Factorio/factorio.app/Contents/MacOS/factorio}"

if [ ! -x "$FACTORIO_BIN" ]; then
  echo "[test] WARN бинарник Factorio не найден: $FACTORIO_BIN" >&2
  echo "[test] WARN задайте FACTORIO_BIN, проверка пропущена" >&2
  exit 0
fi

cd "$ROOT"

python3 tools/check.py
bash scripts/build.sh >/dev/null

NAME="$(python3 -c 'import json; print(json.load(open("info.json"))["name"])')"
VERSION="$(python3 -c 'import json; print(json.load(open("info.json"))["version"])')"
ARCHIVE="$ROOT/dist/${NAME}_${VERSION}.zip"
TEST_MOD="triumphsubstation2-tests"

T="$(mktemp -d "${TMPDIR:-/tmp}/triumph-test.XXXXXX")"
trap 'rm -rf "$T"' EXIT

mkdir -p "$T/mods" "$T/write"
unzip -qo "$ARCHIVE" -d "$T/mods"
cp -R "$ROOT/tests/$TEST_MOD" "$T/mods/"

USER_CONFIG="$HOME/Library/Application Support/factorio/config/config.ini"

make_config() {
  local locale="$1"
  local target="$2"
  if [ -f "$USER_CONFIG" ]; then
    sed -e "s|^write-data=.*|write-data=$T/write|" \
        -e "s|^locale=.*|locale=$locale|" \
        "$USER_CONFIG" > "$target"
  else
    printf '[path]\nwrite-data=%s\n[general]\nlocale=%s\n' "$T/write" "$locale" > "$target"
  fi
}

CONFIG_RU="$T/config-ru.ini"
CONFIG_EN="$T/config-en.ini"
make_config ru "$CONFIG_RU"
make_config en "$CONFIG_EN"

# --- 1. Дамп данных и русской локализации ---
echo "[test] $NAME $VERSION: дамп прототипов и локализации..."
"$FACTORIO_BIN" --config "$CONFIG_EN" --mod-directory "$T/mods" \
  --dump-data --no-log-rotation >"$T/dump-data.log" 2>&1
"$FACTORIO_BIN" --config "$CONFIG_RU" --mod-directory "$T/mods" \
  --dump-prototype-locale --no-log-rotation >"$T/dump-locale.log" 2>&1
python3 tools/smoke.py "$T/write/script-output"

# --- 2. Сценарный тест поведения ---
echo "[test] $NAME $VERSION: сценарный тест ($TEST_MOD/explosion)..."
set +e
"$FACTORIO_BIN" --config "$CONFIG_EN" --mod-directory "$T/mods" \
  --test-scenario "$TEST_MOD/explosion" --test-ticks 300 --no-log-rotation \
  >"$T/scenario.log" 2>&1
CODE=$?
set -e

if [ "$CODE" -ne 0 ]; then
  echo "[test] FAIL (код $CODE). Последние строки лога:" >&2
  tail -40 "$T/scenario.log" >&2
  exit 1
fi

echo "[test] OK: прототипы, локализация и атомный взрыв работают."
