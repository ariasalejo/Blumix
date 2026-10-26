#!/usr/bin/env bash
set -euo pipefail
R="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export BLUMIX_ANIM=0
fail() { printf 'FALLO: %s\n' "$1" >&2; exit 1; }
pass() { printf '[OK] %s\n' "$1"; }

printf 'BLUMIX — pruebas automatizadas\n\n'
[[ -f "$R/bin/blumix" ]] || fail "falta bin/blumix"
pass "ejecutable principal presente"
bash -n "$R/bin/blumix" || fail "sintaxis de bin/blumix"
pass "sintaxis de bin/blumix"

for file in "$R"/lib/*.sh; do
    bash -n "$file" || fail "sintaxis de $file"
    pass "sintaxis de lib/$(basename "$file")"
done

version="$(bash "$R/bin/blumix" version)"
[[ "$version" == "BLUMIX 0.7.0" ]] || fail "versión inesperada: $version"
pass "comando version"

audit="$(bash "$R/bin/blumix" audit --json)" || fail "audit --json devolvió error"
if command -v python3 >/dev/null 2>&1; then
    printf '%s\n' "$audit" | python3 -c '
import json, sys
d = json.load(sys.stdin)
assert d["schema"] == "blumix.audit.v1"
assert d["read_only"] is True
assert d["network_access"] is False
assert {x["id"] for x in d["checks"]} == {"config_permissions", "secret_like_files", "repository_state"}
assert all(x["status"] in {"pass", "warn", "info"} for x in d["checks"])
'
fi
pass "auditoría local JSON: esquema, alcance y controles presentes"

report="$(bash "$R/bin/blumix" report --json)" || fail "report --json devolvió error"
grep -q '"schema": "blumix.snapshot.v1"' <<<"$report" || fail "report no incluye el esquema esperado"
grep -q '"absolute_paths_included": false' <<<"$report" || fail "report no declara el control de privacidad"
if grep -Fq "$HOME" <<<"$report"; then
    fail "report contiene la ruta HOME"
fi
if command -v python3 >/dev/null 2>&1; then
    printf '%s\n' "$report" | python3 -c '
import json, sys
d = json.load(sys.stdin)
assert d["schema"] == "blumix.snapshot.v1"
assert d["safety"]["absolute_paths_included"] is False
assert d["safety"]["secrets_included"] is False
assert set(d["integrations"]) == {"BLUMCL", "BLUMSEC", "BLUMELIX"}
assert all(isinstance(v["directory_found"], bool) for v in d["integrations"].values())
'
fi
pass "instantánea JSON válida y sin rutas absolutas"

atlas="$R/docs/visual-atlas/index.html"
[[ -s "$atlas" ]] || fail "falta el Atlas HTML"
grep -q 'id="snapshot-file"' "$atlas" || fail "Atlas no permite importar instantáneas"
grep -q 'blumix.snapshot.v1' "$atlas" || fail "Atlas no valida el esquema de informe"
grep -q 'No se envía' "$atlas" || grep -q 'no se envía' "$atlas" || fail "Atlas no explica el procesamiento local"
if command -v node >/dev/null 2>&1; then
    node -e 'const fs=require("fs");const html=fs.readFileSync(process.argv[1],"utf8");const match=html.match(/<script>([\s\S]*?)<\/script>/);if(!match)process.exit(2);new Function(match[1]);' "$atlas" || fail "sintaxis JavaScript del Atlas"
    pass "sintaxis JavaScript del Atlas"
fi
if command -v python3 >/dev/null 2>&1; then
    python3 - "$atlas" <<'PY'
from html.parser import HTMLParser
import sys
class AtlasParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = set()
        self.duplicates = set()
    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if key == "id" and value:
                if value in self.ids:
                    self.duplicates.add(value)
                self.ids.add(value)
parser = AtlasParser()
with open(sys.argv[1], encoding="utf-8") as source:
    parser.feed(source.read())
required = {"snapshot-file", "snapshot-status", "report-cpu", "report-ram", "report-disk", "report-uptime"}
missing = required - parser.ids
if parser.duplicates:
    raise SystemExit("IDs duplicados en Atlas: " + ", ".join(sorted(parser.duplicates)))
if missing:
    raise SystemExit("Faltan IDs del Atlas: " + ", ".join(sorted(missing)))
PY
    pass "estructura HTML e identificadores únicos del Atlas"
fi


help="$(bash "$R/bin/blumix" --help)"
grep -q 'doctor' <<<"$help" || fail "help no anuncia doctor"
grep -q 'integrations' <<<"$help" || fail "help no anuncia integrations"
grep -q 'report --json' <<<"$help" || fail "help no anuncia report --json"
grep -q 'audit' <<<"$help" || fail "help no anuncia audit"
pass "ayuda contiene comandos clave"

if bash "$R/bin/blumix" __comando_inexistente >/dev/null 2>&1; then
    fail "un comando desconocido devolvió éxito"
else
    code=$?
    [[ "$code" -eq 2 ]] || fail "código de salida inesperado para comando desconocido: $code"
fi
pass "comando desconocido devuelve código 2"

doctor="$(bash "$R/bin/blumix" doctor)"
grep -q 'Doctor:' <<<"$doctor" || fail "doctor no emitió resumen"
pass "doctor ejecutable"

integration_output="$(BLUMCL_HOME="$R/no-existe-cl" BLUMSEC_HOME="$R/no-existe-sec" BLUMELIX_HOME="$R/no-existe-elx" bash "$R/bin/blumix" integrations)"
grep -q 'BLUMCL' <<<"$integration_output" || fail "integrations omite BLUMCL"
grep -q 'BLUMSEC' <<<"$integration_output" || fail "integrations omite BLUMSEC"
grep -q 'BLUMELIX' <<<"$integration_output" || fail "integrations omite BLUMELIX"
pass "las tres integraciones se reportan explícitamente"

# Comprueba descubrimiento local con diferencias de mayúsculas/minúsculas
# sin tocar los repositorios reales del usuario.
tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT
mkdir -p "$tmp_home/04_DEVELOPMENT/08_Proyectos/Blum/Blumcl" \
         "$tmp_home/04_DEVELOPMENT/08_Proyectos/Blum/BLUMSEC" \
         "$tmp_home/04_DEVELOPMENT/08_Proyectos/Blum/BlumELIX"
if env -u BLUMCL_HOME -u BLUMSEC_HOME -u BLUMELIX_HOME HOME="$tmp_home" bash -c '
    source "$1/lib/core.sh"
    [[ "$BLUMCL_HOME" == "$HOME/04_DEVELOPMENT/08_Proyectos/Blum/Blumcl" ]] &&
    [[ "$BLUMSEC_HOME" == "$HOME/04_DEVELOPMENT/08_Proyectos/Blum/BLUMSEC" ]] &&
    [[ "$BLUMELIX_HOME" == "$HOME/04_DEVELOPMENT/08_Proyectos/Blum/BlumELIX" ]]
' _ "$R"; then
    pass "descubrimiento de rutas tolera mayúsculas/minúsculas"
else
    fail "no se resolvieron correctamente las rutas con capitalización mixta"
fi
rm -rf "$tmp_home"
trap - EXIT

printf '\nTodas las pruebas automatizadas pasaron.\n'
