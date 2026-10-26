#!/usr/bin/env bash
# BLUMIX core: rutas y utilidades compartidas.
BLUMIX_VERSION="0.6.0"
export BLUMIX_ROOT="${BLUMIX_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

blumix_command_exists() { command -v "$1" >/dev/null 2>&1; }
blumix_dir_exists()    { [[ -d "$1" ]]; }
blumix_file_exists()   { [[ -f "$1" ]]; }

# Emit a JSON string without depending on Python, jq, or network access.
# Values passed here are single-line system identifiers and timestamps.
blumix_json_quote() {
    printf '"'
    printf '%s' "${1:-}" | sed 's/\\/\\\\/g; s/"/\\"/g'
    printf '"'
}

# Resolución segura y portable:
# 1) Una variable explícita del usuario siempre prevalece.
# 2) Buscar coincidencia exacta y luego sin distinguir mayúsculas/minúsculas
#    en el directorio actual de proyectos.
# 3) Usar la ruta heredada solo si existe; si no, devolverla como pista.
# No crea, mueve, renombra ni modifica directorios.
blumix_resolve_home() {
    local variable="$1" legacy="$2" project="$3" value candidate base
    value="${!variable:-}"
    if [[ -n "$value" ]]; then
        printf '%s\n' "$value"
        return 0
    fi

    base="$HOME/04_DEVELOPMENT/08_Proyectos/Blum"
    if [[ -d "$base" ]]; then
        candidate="$base/$project"
        if [[ -d "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
        # Linux distingue mayúsculas/minúsculas: Blumcl, BlumCL y BLUMCL
        # pueden ser nombres distintos. Buscamos solo en el primer nivel.
        candidate="$(find "$base" -mindepth 1 -maxdepth 1 -type d -iname "$project" -print -quit 2>/dev/null)"
        if [[ -n "$candidate" && -d "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    fi

    if [[ -d "$legacy" ]]; then
        printf '%s\n' "$legacy"
        return 0
    fi
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
\n') output+='\\n' ;;
            
# Resolución segura y portable:
# 1) Una variable explícita del usuario siempre prevalece.
# 2) Buscar coincidencia exacta y luego sin distinguir mayúsculas/minúsculas
#    en el directorio actual de proyectos.
# 3) Usar la ruta heredada solo si existe; si no, devolverla como pista.
# No crea, mueve, renombra ni modifica directorios.
blumix_resolve_home() {
    local variable="$1" legacy="$2" project="$3" value candidate base
    value="${!variable:-}"
    if [[ -n "$value" ]]; then
        printf '%s\n' "$value"
        return 0
    fi

    base="$HOME/04_DEVELOPMENT/08_Proyectos/Blum"
    if [[ -d "$base" ]]; then
        candidate="$base/$project"
        if [[ -d "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
        # Linux distingue mayúsculas/minúsculas: Blumcl, BlumCL y BLUMCL
        # pueden ser nombres distintos. Buscamos solo en el primer nivel.
        candidate="$(find "$base" -mindepth 1 -maxdepth 1 -type d -iname "$project" -print -quit 2>/dev/null)"
        if [[ -n "$candidate" && -d "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    fi

    if [[ -d "$legacy" ]]; then
        printf '%s\n' "$legacy"
        return 0
    fi
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
\r') output+='\\r' ;;
            
# Resolución segura y portable:
# 1) Una variable explícita del usuario siempre prevalece.
# 2) Buscar coincidencia exacta y luego sin distinguir mayúsculas/minúsculas
#    en el directorio actual de proyectos.
# 3) Usar la ruta heredada solo si existe; si no, devolverla como pista.
# No crea, mueve, renombra ni modifica directorios.
blumix_resolve_home() {
    local variable="$1" legacy="$2" project="$3" value candidate base
    value="${!variable:-}"
    if [[ -n "$value" ]]; then
        printf '%s\n' "$value"
        return 0
    fi

    base="$HOME/04_DEVELOPMENT/08_Proyectos/Blum"
    if [[ -d "$base" ]]; then
        candidate="$base/$project"
        if [[ -d "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
        # Linux distingue mayúsculas/minúsculas: Blumcl, BlumCL y BLUMCL
        # pueden ser nombres distintos. Buscamos solo en el primer nivel.
        candidate="$(find "$base" -mindepth 1 -maxdepth 1 -type d -iname "$project" -print -quit 2>/dev/null)"
        if [[ -n "$candidate" && -d "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    fi

    if [[ -d "$legacy" ]]; then
        printf '%s\n' "$legacy"
        return 0
    fi
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
\t') output+='\\t' ;;
            *) output+="$ch" ;;
        esac
    done
    printf '"%s"' "$output"
}

# Resolución segura y portable:
# 1) Una variable explícita del usuario siempre prevalece.
# 2) Buscar coincidencia exacta y luego sin distinguir mayúsculas/minúsculas
#    en el directorio actual de proyectos.
# 3) Usar la ruta heredada solo si existe; si no, devolverla como pista.
# No crea, mueve, renombra ni modifica directorios.
blumix_resolve_home() {
    local variable="$1" legacy="$2" project="$3" value candidate base
    value="${!variable:-}"
    if [[ -n "$value" ]]; then
        printf '%s\n' "$value"
        return 0
    fi

    base="$HOME/04_DEVELOPMENT/08_Proyectos/Blum"
    if [[ -d "$base" ]]; then
        candidate="$base/$project"
        if [[ -d "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
        # Linux distingue mayúsculas/minúsculas: Blumcl, BlumCL y BLUMCL
        # pueden ser nombres distintos. Buscamos solo en el primer nivel.
        candidate="$(find "$base" -mindepth 1 -maxdepth 1 -type d -iname "$project" -print -quit 2>/dev/null)"
        if [[ -n "$candidate" && -d "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    fi

    if [[ -d "$legacy" ]]; then
        printf '%s\n' "$legacy"
        return 0
    fi
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
