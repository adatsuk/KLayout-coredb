#!/usr/bin/env bash
# Link CommonDB mcore streamer into the vendored KLayout tree and write local.pri.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KLAYOUT="${1:-$ROOT/klayout-src}"
if [[ "$KLAYOUT" != /* ]]; then
  KLAYOUT="$(cd "$(dirname "$KLAYOUT")" && pwd)/$(basename "$KLAYOUT")"
fi

if [[ -n "${COMMONDB_ROOT:-}" ]]; then
  COMMONDB="$(cd "$COMMONDB_ROOT" && pwd)"
elif [[ -d "$ROOT/../CommonDB" ]]; then
  COMMONDB="$(cd "$ROOT/../CommonDB" && pwd)"
else
  echo "COMMONDB_ROOT not set and ../CommonDB not found" >&2
  exit 1
fi

STREAMERS="$KLAYOUT/src/plugins/streamers"
MCORE="$ROOT/integrations/klayout/mcore"
LINK="$STREAMERS/mcore"

if [[ ! -d "$KLAYOUT/src" ]]; then
  echo "KLayout not found at $KLAYOUT" >&2
  exit 1
fi

mkdir -p "$STREAMERS"
if [[ -L "$LINK" ]] || [[ -e "$LINK" ]]; then
  rm -rf "$LINK"
fi
ln -s "$MCORE" "$LINK"

mkdir -p "$MCORE/db_plugin"
cat > "$MCORE/db_plugin/local.pri" <<EOF
COMMONDB_ROOT = $COMMONDB
KLAYOUT_SRC = $KLAYOUT/src
EOF

# Ensure streamers.pro includes mcore (idempotent).
STREAMERS_PRO="$STREAMERS/streamers.pro"
if ! grep -q 'SUBDIRS += mcore' "$STREAMERS_PRO" 2>/dev/null; then
  printf '\n# CommonDB CORE streamer\nSUBDIRS += mcore\n' >> "$STREAMERS_PRO"
fi

echo "Linked $LINK -> $MCORE"
echo "COMMONDB_ROOT=$COMMONDB"
echo "KLAYOUT_SRC=$KLAYOUT/src"
