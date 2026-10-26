#!/usr/bin/env bash
# BLUMIX core: rutas y utilidades compartidas.
BLUMIX_VERSION="0.7.0"
export BLUMIX_ROOT="${BLUMIX_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

blumix_command_exists() { command -v "$1" >/dev/null 2>&1; }
blumix_dir_exists()    { [[ -d "$1" ]]; }
blumix_file_exists()   { [[ -f "$1" ]]; }

# Emite una cadena JSON escapando barras inversas y comillas.
# Los valores del snapshot son identificadores de una sola línea.
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

BLUMIX_ENV_BLUMCL_HOME_SET=0; [[ -n "${BLUMCL_HOME:-}" ]] && BLUMIX_ENV_BLUMCL_HOME_SET=1
BLUMIX_ENV_BLUMSEC_HOME_SET=0; [[ -n "${BLUMSEC_HOME:-}" ]] && BLUMIX_ENV_BLUMSEC_HOME_SET=1
BLUMIX_ENV_BLUMELIX_HOME_SET=0; [[ -n "${BLUMELIX_HOME:-}" ]] && BLUMIX_ENV_BLUMELIX_HOME_SET=1
export BLUMCL_HOME="$(blumix_resolve_home BLUMCL_HOME "$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumcl" "Blumcl")"
export BLUMSEC_HOME="$(blumix_resolve_home BLUMSEC_HOME "$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumsec" "Blumsec")"
export BLUMELIX_HOME="$(blumix_resolve_home BLUMELIX_HOME "$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumelix" "Blumelix")"

# Lee una lista cerrada de asignaciones; nunca ejecuta la configuración como Bash.
# Solo se expande el prefijo literal $HOME en las rutas, no variables ni comandos arbitrarios.
blumix_load_config() {
    local cfg="${BLUMIX_CONFIG:-$BLUMIX_ROOT/config/blumix.conf}"
    local line key value
    [[ -f "$cfg" && -r "$cfg" ]] || return 0

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%$'\r'}"
        [[ "$line" =~ ^[[:space:]]*(#.*)?$ ]] && continue
        if [[ ! "$line" =~ ^[[:space:]]*([A-Z_][A-Z0-9_]*)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
            printf '[BLUMIX] Configuración: línea inválida ignorada.\n' >&2
            continue
        fi
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"
        if [[ "$value" == \"*\" && "$value" == *\" ]]; then
            value="${value:1:${#value}-2}"
        elif [[ "$value" == \'*\' && "$value" == *\' ]]; then
            value="${value:1:${#value}-2}"
        fi

        case "$key" in
            BLUMCL_HOME|BLUMSEC_HOME|BLUMELIX_HOME)
                # Variables de entorno explícitas prevalecen sobre el archivo.
                case "$value" in
                    '$HOME'|'$HOME/'*) value="$HOME${value#\$HOME}" ;;
                    '${HOME}'|'${HOME}/'*) value="$HOME${value#\$\{HOME\}}" ;;
                esac
                [[ -n "$value" ]] || continue
                case "$key" in
                    BLUMCL_HOME) [[ "${BLUMIX_ENV_BLUMCL_HOME_SET:-0}" == 1 ]] || export BLUMCL_HOME="$value" ;;
                    BLUMSEC_HOME) [[ "${BLUMIX_ENV_BLUMSEC_HOME_SET:-0}" == 1 ]] || export BLUMSEC_HOME="$value" ;;
                    BLUMELIX_HOME) [[ "${BLUMIX_ENV_BLUMELIX_HOME_SET:-0}" == 1 ]] || export BLUMELIX_HOME="$value" ;;
                esac
                ;;
            BLUMIX_THEME)
                [[ "$value" == "dark" || "$value" == "light" ]] && export BLUMIX_THEME="$value" || printf '[BLUMIX] Configuración: valor de tema ignorado.\n' >&2
                ;;
            BLUMIX_LANG)
                [[ "$value" == "es" || "$value" == "en" ]] && export BLUMIX_LANG="$value" || printf '[BLUMIX] Configuración: idioma no admitido.\n' >&2
                ;;
            BLUMIX_AI_ENABLED)
                [[ "$value" == "0" || "$value" == "1" || "$value" == "false" || "$value" == "true" ]] && export BLUMIX_AI_ENABLED="$value" || printf '[BLUMIX] Configuración: valor de IA ignorado.\n' >&2
                ;;
            BLUMIX_ANIM)
                [[ "$value" == "0" || "$value" == "1" || "$value" == "auto" ]] && export BLUMIX_ANIM="$value" || printf '[BLUMIX] Configuración: valor de animación ignorado.\n' >&2
                ;;
            *)
                printf '[BLUMIX] Configuración: clave no permitida ignorada.\n' >&2
                ;;
        esac
    done < "$cfg"
    return 0
}
