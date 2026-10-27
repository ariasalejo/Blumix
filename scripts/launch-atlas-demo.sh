#!/usr/bin/env bash
# BLUMIX Atlas demo — serves only on loopback; no installation or file writes.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${BLUMIX_ATLAS_PORT:-8787}"
ATLAS_DIR="$ROOT/docs/visual-atlas"

if ! command -v python3 >/dev/null 2>&1; then
  printf '[ERROR] Python 3 no está instalado.\n' >&2
  exit 127
fi
if [[ ! -s "$ATLAS_DIR/index.html" ]]; then
  printf '[ERROR] No se encuentra el Atlas: %s/index.html\n' "$ATLAS_DIR" >&2
  exit 2
fi
if [[ ! "$PORT" =~ ^[0-9]{1,5}$ ]] || (( PORT < 1024 || PORT > 65535 )); then
  printf '[ERROR] BLUMIX_ATLAS_PORT debe ser un puerto libre entre 1024 y 65535.\n' >&2
  exit 2
fi

printf 'BLUMIX ATLAS · DEMO LOCAL\n'
printf 'Dirección: http://127.0.0.1:%s/\n' "$PORT"
printf 'Archivos servidos: %s\n' "$ATLAS_DIR"
printf 'Red: solo loopback (127.0.0.1) · sin sudo · sin cambios de sistema\n'
printf 'Para detener: Ctrl+C\n\n'
exec python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$ATLAS_DIR"
