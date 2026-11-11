#!/usr/bin/env bash
# Обновляет оформление страницы мода на Mod Portal (не релизы).
# Берёт title/summary/category/tags/license/homepage/source_url из
# portal/metadata.json, а описание — из portal/description.md (markdown).
#
# Требуется токен API с правом «ModPortal: Edit Mods».
# Токен берётся из MOD_PORTAL_TOKEN или файла .mod-portal-token.
#
# Использование:
#   scripts/portal-details.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PORTAL="https://mods.factorio.com"
EDIT_DETAILS="$PORTAL/api/v2/mods/edit_details"
META="portal/metadata.json"
DESCRIPTION="portal/description.md"

for file in "$META" "$DESCRIPTION"; do
  if [ ! -f "$file" ]; then
    echo "ERROR: не найден $file" >&2
    exit 1
  fi
done

TOKEN="${MOD_PORTAL_TOKEN:-}"
if [ -z "$TOKEN" ] && [ -f .mod-portal-token ]; then
  TOKEN="$(cat .mod-portal-token)"
fi
if [ -z "$TOKEN" ]; then
  echo "ERROR: токен не найден. Задайте MOD_PORTAL_TOKEN или создайте .mod-portal-token" >&2
  exit 1
fi

NAME="$(python3 -c 'import json; print(json.load(open("info.json"))["name"])')"

meta() {
  python3 -c "import json,sys; print(json.load(open('$META'))[$1])"
}

TITLE="$(meta "'title'")"
SUMMARY="$(meta "'summary'")"
CATEGORY="$(meta "'category'")"
LICENSE="$(meta "'license'")"
HOMEPAGE="$(meta "'homepage'")"
SOURCE="$(meta "'source_url'")"

TAG_ARGS=()
while IFS= read -r tag; do
  [ -n "$tag" ] && TAG_ARGS+=(--form-string "tags=$tag")
done < <(python3 -c "import json; print('\n'.join(json.load(open('$META'))['tags']))")

echo "[portal] проверка '$NAME' на Mod Portal..."
if ! curl -sS -f -o /dev/null "$PORTAL/api/mods/$NAME"; then
  echo "ERROR: мод '$NAME' не найден. Сначала создайте страницу: $PORTAL/mods/new" >&2
  exit 1
fi

echo "[portal] обновление описания и категории..."
RESP="$(curl -sS -X POST "$EDIT_DETAILS" \
  -H "Authorization: Bearer $TOKEN" \
  --form-string "mod=$NAME" \
  --form-string "title=$TITLE" \
  --form-string "summary=$SUMMARY" \
  --form-string "category=$CATEGORY" \
  --form-string "license=$LICENSE" \
  --form-string "homepage=$HOMEPAGE" \
  --form-string "source_url=$SOURCE" \
  "${TAG_ARGS[@]}" \
  -F "description=<$DESCRIPTION")"

if printf '%s' "$RESP" | grep -q '"success":true'; then
  echo "[portal] OK: страница обновлена — $PORTAL/mod/$NAME"
else
  echo "ERROR: не удалось обновить страницу: $RESP" >&2
  exit 1
fi
