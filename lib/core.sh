#!/usr/bin/env bash
BLUMIX_VERSION="0.3.0"
export BLUMIX_ROOT="${BLUMIX_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export BLUMCL_HOME="${BLUMCL_HOME:-$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumcl}"
export BLUMSEC_HOME="${BLUMSEC_HOME:-$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumsec}"
export BLUMELIX_HOME="${BLUMELIX_HOME:-$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumelix}"
blumix_command_exists() { command -v "$1" >/dev/null 2>&1; }
blumix_dir_exists()    { [[ -d "$1" ]]; }
blumix_file_exists()   { [[ -f "$1" ]]; }
blumix_load_config() {
    local cfg="${BLUMIX_CONFIG:-$BLUMIX_ROOT/config/blumix.conf}"
    [[ -f "$cfg" ]] && source "$cfg"
    return 0
}
