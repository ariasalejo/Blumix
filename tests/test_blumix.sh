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
[[ "$version" == "BLUMIX 0.6.0" ]] || fail "versión inesperada: $version"
pass "comando version"

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


help="$(bash "$R/bin/blumix" --help)"
grep -q 'doctor' <<<"$help" || fail "help no anuncia doctor"
grep -q 'integrations' <<<"$help" || fail "help no anuncia integrations"
grep -q 'report --json' <<<"$help" || fail "help no anuncia report --json"
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
