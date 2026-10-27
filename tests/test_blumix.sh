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

intel="$(bash "$R/bin/blumix" intelligence)" || fail "intelligence devolvió error"
grep -q 'CENTRO DE INTELIGENCIA' <<<"$intel" || fail "intelligence no muestra el centro de diagnóstico"
grep -q 'INTEGRIDAD DEL ECOSISTEMA' <<<"$intel" || fail "intelligence no revisa integraciones"
grep -q 'HERRAMIENTAS CLAVE' <<<"$intel" || fail "intelligence no detecta herramientas"
grep -q 'no cambia servicios ni archivos' <<<"$intel" || fail "intelligence no declara sus límites de solo lectura"
intel_alias="$(bash "$R/bin/blumix" intel)" || fail "alias intel devolvió error"
grep -q 'CENTRO DE INTELIGENCIA' <<<"$intel_alias" || fail "alias intel no funciona"
pass "centro de inteligencia: diagnóstico local, recomendaciones y límites explícitos"

intel_json="$(bash "$R/bin/blumix" intelligence --json)" || fail "intelligence --json devolvió error"
if command -v python3 >/dev/null 2>&1; then
    printf '%s\n' "$intel_json" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["schema"]=="blumix.intelligence.v1"; assert d["safety"]["read_only"] is True; assert d["safety"]["service_health_checked"] is False; assert {x["id"] for x in d["checks"]}=={"cpu","memory","root_disk"}; assert all(x["status"] in {"OBSERVED","REVIEW","DEGRADED","UNKNOWN"} for x in d["checks"])'
fi
pass "intelligence --json: esquema, fuentes y límites de salud"
if bash "$R/bin/blumix" intelligence --invalid >/dev/null 2>&1; then fail "intelligence aceptó un argumento desconocido"; else code=$?; [[ "$code" -eq 2 ]] || fail "intelligence no devolvió código 2"; fi
pass "argumentos inválidos de intelligence devuelven código 2"

projects_text="$(bash "$R/bin/blumix" projects)" || fail "projects devolvió error"
grep -q 'BLUMCL' <<<"$projects_text" || fail "projects omite BLUMCL"
grep -q 'BLUMSEC' <<<"$projects_text" || fail "projects omite BLUMSEC"
grep -q 'BLUMELIX' <<<"$projects_text" || fail "projects omite BLUMELIX"
grep -q 'UNKNOWN' <<<"$projects_text" || fail "projects no declara salud desconocida"
services_text="$(bash "$R/bin/blumix" services)" || fail "services devolvió error"
grep -q 'UNKNOWN' <<<"$services_text" || fail "services no declara limitaciones"
projects_json="$(bash "$R/bin/blumix" projects --json)" || fail "projects --json devolvió error"
services_json="$(bash "$R/bin/blumix" services --json)" || fail "services --json devolvió error"
if command -v python3 >/dev/null 2>&1; then
    printf '%s\n' "$projects_json" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["schema"]=="blumix.projects.v1"; assert d["read_only"] is True; assert {x["id"] for x in d["projects"]}=={"BLUMCL","BLUMSEC","BLUMELIX"}; assert all(x["functional_health"]=="UNKNOWN" for x in d["projects"])'
    printf '%s\n' "$services_json" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["schema"]=="blumix.services.v1"; assert d["read_only"] is True; assert d["functional_health"]=="UNKNOWN"; assert isinstance(d["processes"],list) and isinstance(d["services"],list)'
fi
pass "inventario y observación de servicios: JSON válido y sin falsos positivos de salud"
if bash "$R/bin/blumix" projects --bad >/dev/null 2>&1; then fail "projects aceptó un argumento desconocido"; else code=$?; [[ "$code" -eq 2 ]] || fail "projects no devolvió código 2"; fi
if bash "$R/bin/blumix" services --bad >/dev/null 2>&1; then fail "services aceptó un argumento desconocido"; else code=$?; [[ "$code" -eq 2 ]] || fail "services no devolvió código 2"; fi
pass "argumentos inválidos de projects/services devuelven código 2"

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
policy="$(bash "$R/bin/blumix" policy --json)" || fail "policy --json devolvió error"
if command -v python3 >/dev/null 2>&1; then
    printf '%s\n' "$policy" | python3 -c '
import json, sys
d = json.load(sys.stdin)
assert d["schema"] == "blumix.policy.v1"
assert d["default_deny"] is True
assert d["privileged_agent"]["elevation_enabled"] is False
ops = {x["id"]: x for x in d["operations"]}
assert ops["restart_service"]["status"] == "blocked"
assert ops["apply_system_change"]["status"] == "blocked"
assert ops["run_shell"]["status"] == "denied"
assert d["safety"]["executes_operations"] is False
assert d["safety"]["invokes_sudo"] is False
'
fi
pass "catálogo de capacidades: denegar por defecto y sin elevación"

# La configuración se interpreta como datos: nunca se ejecuta como Bash.
config_tmp="$(mktemp -d)"
trap 'rm -rf "$config_tmp"' EXIT
mkdir -p "$config_tmp/home"
marker="$config_tmp/SHOULD_NOT_EXIST"
printf 'BLUMCL_HOME="%s/from-config"\nBLUMIX_THEME="$(touch %s)"\n' "$config_tmp" "$marker" > "$config_tmp/config"
if env -u BLUMCL_HOME BLUMIX_CONFIG="$config_tmp/config" HOME="$config_tmp/home" bash -c '
    source "$1/lib/core.sh"
    blumix_load_config
    [[ "$BLUMCL_HOME" == "$2/from-config" ]]
' _ "$R" "$config_tmp"; then
    [[ ! -e "$marker" ]] || fail "la configuración ejecutó una sustitución de comandos"
    pass "configuración restringida: sin ejecución de código"
else
    fail "no se pudo leer configuración segura"
fi
if BLUMCL_HOME="$config_tmp/from-env" BLUMIX_CONFIG="$config_tmp/config" HOME="$config_tmp/home" bash -c '
    source "$1/lib/core.sh"
    blumix_load_config
    [[ "$BLUMCL_HOME" == "$2/from-env" ]]
' _ "$R" "$config_tmp"; then
    pass "variable de entorno explícita prevalece sobre configuración"
else
    fail "la configuración sobrescribió una ruta explícita del entorno"
fi
rm -rf "$config_tmp"
trap - EXIT

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
grep -q 'function validateSnapshot' "$atlas" || fail "Atlas no valida tipos y rangos del informe"
grep -q 'NO FIRMADO' "$atlas" || fail "Atlas no advierte que el informe no está firmado"
[[ -s "$R/docs/visual-atlas/manifest.webmanifest" ]] || fail "falta manifiesto PWA"
[[ -s "$R/docs/visual-atlas/sw.js" ]] || fail "falta service worker PWA"
grep -q 'No se envía' "$atlas" || grep -q 'no se envía' "$atlas" || fail "Atlas no explica el procesamiento local"
grep -q 'Tu ecosistema' "$atlas" || fail "Atlas no usa el diseño de centro de mando"
grep -q 'AGENTE PRIVILEGIADO' "$atlas" || fail "Atlas no muestra estado del agente"
grep -q 'run_shell' "$atlas" || fail "Atlas no documenta el bloqueo de shell arbitraria"
if command -v node >/dev/null 2>&1; then
    node -e 'const fs=require("fs");const html=fs.readFileSync(process.argv[1],"utf8");const match=html.match(/<script>([\s\S]*?)<\/script>/);if(!match)process.exit(2);new Function(match[1]);' "$atlas" || fail "sintaxis JavaScript del Atlas"
    pass "sintaxis JavaScript del Atlas"
    node --check "$R/docs/visual-atlas/sw.js" || fail "sintaxis del service worker"
    pass "sintaxis del service worker PWA"
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
    python3 - "$R/docs/visual-atlas/manifest.webmanifest" <<'PYMANIFEST'
import json, sys
with open(sys.argv[1], encoding="utf-8") as source:
    manifest = json.load(source)
assert manifest["name"].startswith("BLUMIX")
assert manifest["display"] == "standalone"
assert manifest["start_url"] == "./index.html"
PYMANIFEST
    pass "estructura HTML, manifiesto PWA e identificadores únicos del Atlas"
fi


help="$(bash "$R/bin/blumix" --help)"
grep -q 'doctor' <<<"$help" || fail "help no anuncia doctor"
grep -q 'integrations' <<<"$help" || fail "help no anuncia integrations"
grep -q 'report --json' <<<"$help" || fail "help no anuncia report --json"
grep -q 'audit' <<<"$help" || fail "help no anuncia audit"
grep -q 'policy' <<<"$help" || fail "help no anuncia policy"
grep -q 'intelligence' <<<"$help" || fail "help no anuncia intelligence"
grep -q 'brain status|demo' <<<"$help" || fail "help no anuncia brain"
pass "ayuda contiene comandos clave"

brain_status="$(bash "$R/bin/blumix" brain status)" || fail "brain status falló"
grep -q 'BLUMIX BRAIN' <<<"$brain_status" || fail "brain status no identifica el motor"
grep -q 'no ejecuta comandos' <<<"$brain_status" || fail "brain status no declara límites"
brain_demo="$(bash "$R/bin/blumix" brain demo --epochs 20)" || fail "brain demo falló"
grep -q 'datos sintéticos' <<<"$brain_demo" || fail "brain demo no advierte sobre datos sintéticos"
grep -q 'No se guardó ningún archivo' <<<"$brain_demo" || fail "brain demo no declara que no escribe modelos"
if bash "$R/bin/blumix" brain comando-desconocido >/dev/null 2>&1; then
    fail "brain aceptó un subcomando desconocido"
else
    code=$?
    [[ "$code" -eq 2 ]] || fail "brain desconocido no devolvió código 2"
fi
python3 "$R/tests/test_brain.py" >/dev/null || fail "pruebas del motor neuronal fallaron"
pass "motor neuronal experimental: entrenamiento, validación, serialización y límites"

# Capacidades avanzadas de terminal: rutas explícitas, autocompletado y menú seguro.
completion="$(bash "$R/bin/blumix" completion bash)" || fail "completion bash falló"
grep -q 'complete -F _blumix_complete blumix' <<<"$completion" || fail "autocompletado Bash incompleto"
pass "autocompletado Bash para comandos y opciones"
paths="$(bash "$R/bin/blumix" paths)" || fail "paths falló"
grep -q 'BLUMCL:' <<<"$paths" || fail "paths omite BLUMCL"
grep -q 'BLUMELIX:' <<<"$paths" || fail "paths omite BLUMELIX"
pass "rutas configuradas visibles bajo petición explícita"
if bash "$R/bin/blumix" completion zsh >/dev/null 2>&1; then fail "completion aceptó una shell no soportada"; else code=$?; [[ "$code" -eq 2 ]] || fail "completion inválido no devolvió código 2"; fi
if bash "$R/bin/blumix" watch 1 >/dev/null 2>&1; then fail "watch aceptó un intervalo inferior al mínimo"; else code=$?; [[ "$code" -eq 2 ]] || fail "watch inválido no devolvió código 2"; fi
pass "validación estricta de argumentos de funciones avanzadas"

# El centro interactivo debe ser visual, navegable y no depender del árbol ASCII.
grep -q 'ORQUESTADOR BLUMIX' "$R/lib/tui.sh" || fail "falta la raíz lógica del orquestador"
grep -q 'NUCLEO DEL SISTEMA' "$R/lib/tui.sh" || fail "falta el dominio del sistema"
grep -q 'MOTOR DE INTELIGENCIA' "$R/lib/tui.sh" || fail "falta el dominio de inteligencia"
grep -q 'ECOSISTEMA DE PROYECTOS' "$R/lib/tui.sh" || fail "falta el dominio de proyectos"
grep -q 'BOVEDA DE EVIDENCIAS' "$R/lib/tui.sh" || fail "falta el dominio de evidencias"
grep -q 'blumix_tui_render_card' "$R/lib/tui.sh" || fail "falta el renderizador visual de tarjetas"
grep -q 'COMMAND CENTER' "$R/lib/tui.sh" || fail "falta el encabezado del centro de mando"
if grep -q 'blumix_tui_render_node' "$R/lib/tui.sh"; then fail "sigue presente el renderizador recursivo del árbol ASCII"; fi
if bash "$R/bin/blumix" menu >/dev/null 2>&1; then
    fail "menu aceptó ejecución sin terminal interactiva"
else
    code=$?
    [[ "$code" -eq 2 ]] || fail "menu no interactivo no devolvió código 2"
fi
rendered_dashboard="$(bash -c 'source "$1/lib/core.sh"; source "$1/lib/ui.sh"; source "$1/lib/tui.sh"; blumix_load_config; BLX_VISIBLE_NODES=(0 1 4 7 10 13 16 18 20); blumix_tui_render 0' _ "$R")" || fail "el centro de mando no pudo renderizarse"
grep -q 'COMMAND CENTER' <<<"$rendered_dashboard" || fail "el renderizado no muestra el centro de mando"
grep -q 'Vista general' <<<"$rendered_dashboard" || fail "el renderizado no muestra la vista general"
grep -q 'NUCLEO DEL SISTEMA' <<<"$rendered_dashboard" || fail "el renderizado no muestra el dominio del sistema"
grep -q 'BOVEDA DE EVIDENCIAS' <<<"$rendered_dashboard" || fail "el renderizado no muestra el dominio de evidencias"
grep -q 'EN FOCO' <<<"$rendered_dashboard" || fail "el renderizado no resalta la selección"
pass "centro de mando visual: tarjetas, selección y telemetría"
pass "navegación jerárquica sin renderizador de árbol ASCII y modo no interactivo seguro"

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
