#!/usr/bin/env bash
blumix_integrations() {
    blx_title "INTEGRACIONES — DESCUBRIMIENTO LOCAL"
    local name path
    for name in BLUMCL BLUMSEC BLUMELIX; do
        case "$name" in
            BLUMCL) path="$BLUMCL_HOME" ;;
            BLUMSEC) path="$BLUMSEC_HOME" ;;
            BLUMELIX) path="$BLUMELIX_HOME" ;;
        esac
        if [[ -d "$path" ]]; then
            blx_row "$name: directorio encontrado"
            printf '       %s\n' "$path"
        else
            blx_warn "$name: directorio no encontrado"
            printf '       Ruta configurada: %s\n' "$path"
        fi
    done
    blx_warn "Presencia de directorio no equivale a integración funcional o servicio saludable."
    blx_bottom
}

blumix_go_blumcl() { blumix_open_project "BLUMCL" "$BLUMCL_HOME"; }
blumix_go_blumsec() { blumix_open_project "BLUMSEC" "$BLUMSEC_HOME"; }
blumix_go_blumelix() { blumix_open_project "BLUMELIX" "$BLUMELIX_HOME"; }

blumix_open_project() {
    local name="$1" path="$2"
    if [[ -d "$path" ]]; then
        printf '%s\n' "Abriendo $name: $path"
        cd "$path" || return 1
        exec "${SHELL:-/bin/bash}" -i
    fi
    printf 'BLUMIX: no se encontró el directorio de %s: %s\n' "$name" "$path" >&2
    printf 'Define la variable %s_HOME con la ruta correcta.\n' "$name" >&2
    return 1
}
