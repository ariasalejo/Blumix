#!/usr/bin/env bash
# BLUMIX core: rutas y utilidades compartidas.
BLUMIX_VERSION="0.4.0"
export BLUMIX_ROOT="${BLUMIX_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

blumix_command_exists() { command -v "$1" >/dev/null 2>&1; }
blumix_dir_exists()    { [[ -d "$1" ]]; }
blumix_file_exists()   { [[ -f "$1" ]]; }

# Respeta primero la variable explícita; luego una ruta existente conocida;
# por último conserva el destino legado como fallback no destructivo.
blumix_resolve_home() {
    local variable="$1" legacy="$2" project="$3" value candidate
    value="${!variable:-}"
    if [[ -n "$value" ]]; then
        printf '%s\n' "$value"
        return
    fi
    if [[ -d "$legacy" ]]; then
        printf '%s\n' "$legacy"
        return
    fi
    for candidate in \
        "$HOME/04_DEVELOPMENT/08_Proyectos/Blum/$project" \
        "$HOME/04_DEVELOPMENT/08_Proyectos/Blum/${project,,}"; do
        if [[ -d "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return
        fi
    done
    printf '%s\n' "$legacy"
}

export BLUMCL_HOME="$(blumix_resolve_home BLUMCL_HOME "$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumcl" "Blumcl")"
export BLUMSEC_HOME="$(blumix_resolve_home BLUMSEC_HOME "$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumsec" "Blumsec")"
export BLUMELIX_HOME="$(blumix_resolve_home BLUMELIX_HOME "$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumelix" "Blumelix")"

blumix_load_config() {
    local cfg="${BLUMIX_CONFIG:-$BLUMIX_ROOT/config/blumix.conf}"
    # Solo cargar configuración local explícita: este archivo se interpreta como Bash.
    if [[ -f "$cfg" && -r "$cfg" ]]; then
        # shellcheck source=/dev/null
        source "$cfg"
    fi
    return 0
}
