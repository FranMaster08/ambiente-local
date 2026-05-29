#!/usr/bin/env bash
# Instala el hook pre-commit en el repositorio git actual (ambiente-local o submódulo).
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SRC="${SCRIPT_DIR}/hooks/pre-commit"
HOOK_DST="${ROOT}/.git/hooks/pre-commit"

if [ ! -f "$HOOK_SRC" ]; then
  echo "No se encontró ${HOOK_SRC}" >&2
  exit 1
fi

cp "$HOOK_SRC" "$HOOK_DST"
chmod +x "$HOOK_DST"
echo "Hook instalado en ${HOOK_DST}"
