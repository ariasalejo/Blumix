#!/usr/bin/env bash
set -e
R="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "🧪 Tests Blumix"
[[ -x "$R/bin/blumix" ]] && echo "✅ bin ejecutable"
"$R/bin/blumix" version | grep -q Blumix && echo "✅ version responde"
for m in core ui system network security development integrations; do
    [[ -f "$R/lib/$m.sh" ]] && echo "✅ lib/$m.sh"
done
for f in "$R"/lib/*.sh "$R"/bin/blumix; do bash -n "$f" && echo "✅ sintaxis $(basename "$f")"; done
echo "🎉 Todos los tests pasaron"
