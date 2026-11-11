#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-2.1.0}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/src/TriumphSubstation_$VERSION"
DIST="$ROOT/dist"

if [ ! -d "$SRC" ]; then
  echo "Source directory not found: $SRC" >&2
  exit 1
fi

mkdir -p "$DIST"
rm -f "$DIST/TriumphSubstation_$VERSION.zip"

(
  cd "$ROOT/src"
  zip -r "$DIST/TriumphSubstation_$VERSION.zip" "TriumphSubstation_$VERSION"
)

echo "Created $DIST/TriumphSubstation_$VERSION.zip"
