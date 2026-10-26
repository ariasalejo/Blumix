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
[[ "$version" == "BLUMIX 0.4.0" ]] || fail "versión inesperada: $version"
pass "comando version"

help="$(bash "$R/bin/blumix" --help)"
grep -q 'doctor' <<<"$help" || fail "help no anuncia doctor"
grep -q 'integrations' <<<"$help" || fail "help no anuncia integrations"
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

printf '\nTodas las pruebas automatizadas pasaron.\n'
