#!/usr/bin/env bash
# Evidencia local del ecosistema. Solo lectura; no demuestra salud funcional.
blumix_projects() {
    local mode="$1" generated name path state evidence comma=""
    [[ -n "$mode" ]] || mode=text
    [[ "$mode" == text || "$mode" == json ]] || { printf 'Uso: blumix projects [--json]\n' >&2; return 2; }
    generated="$(date -Is 2>/dev/null || date -u '+%Y-%m-%dT%H:%M:%SZ')"
    if [[ "$mode" == json ]]; then
        printf '{\n  "schema": "blumix.projects.v1",\n  "generated_at": '
        blumix_json_quote "$generated"
        printf ',\n  "read_only": true,\n  "projects": [\n'
    else
        printf 'BLUMIX — INVENTARIO DE PROYECTOS\nEvidencia local · %s\n\n' "$generated"
    fi
    for name in BLUMCL BLUMSEC BLUMELIX; do
        case "$name" in
            BLUMCL) path="$BLUMCL_HOME" ;;
            BLUMSEC) path="$BLUMSEC_HOME" ;;
            BLUMELIX) path="$BLUMELIX_HOME" ;;
        esac
        if [[ -d "$path" ]]; then
            if [[ -d "$path/.git" || -f "$path/.git" ]]; then
                state="GIT_DETECTED"; evidence="directory_and_git_metadata"
            else
                state="DISCOVERED"; evidence="directory_only"
            fi
        else
            state="NOT_FOUND"; evidence="configured_path_not_present"
        fi
        if [[ "$mode" == json ]]; then
            printf '    %s{"id": ' "$comma"; blumix_json_quote "$name"
            printf ', "state": '; blumix_json_quote "$state"
            printf ', "evidence": '; blumix_json_quote "$evidence"
            printf ', "source": "filesystem", "checked_at": '
            blumix_json_quote "$generated"
            printf ', "functional_health": "UNKNOWN", "limitations": "Carpeta o Git no demuestra que la aplicación funcione."}'
            comma=$',\n'
        else
            printf '[%s] %s\n' "$state" "$name"
            printf '  Ruta inspeccionada: %s\n' "$path"
        fi
    done
    if [[ "$mode" == json ]]; then
        printf '\n  ],\n  "safety": {"network_access": false, "writes_files": false}\n}\n'
    else
        printf '\nSalud funcional: UNKNOWN. No se ejecutan pruebas ni se infiere que haya servicios activos.\n'
    fi
}

blumix_services() {
    local mode="$1" generated first=1 pid comm unit
    [[ -n "$mode" ]] || mode=text
    [[ "$mode" == text || "$mode" == json ]] || { printf 'Uso: blumix services [--json]\n' >&2; return 2; }
    generated="$(date -Is 2>/dev/null || date -u '+%Y-%m-%dT%H:%M:%SZ')"
    if [[ "$mode" == json ]]; then
        printf '{\n  "schema": "blumix.services.v1",\n  "generated_at": '
        blumix_json_quote "$generated"
        printf ',\n  "read_only": true,\n  "processes": ['
    else
        printf 'BLUMIX — PROCESOS Y SERVICIOS OBSERVABLES\nEvidencia local · %s\n' "$generated"
    fi
    if blumix_command_exists ps; then
        while read -r pid comm; do
            [[ "$pid" =~ ^[0-9]+$ && -n "$comm" ]] || continue
            case "$comm" in
                *[Bb][Ll][Uu][Mm][Ii][Xx]*|*[Bb][Ll][Uu][Mm][Cc][Ll]*|*[Bb][Ll][Uu][Mm][Ss][Ee][Cc]*|*[Bb][Ll][Uu][Mm][Ee][Ll][Ii][Xx]*)
                    if [[ "$mode" == json ]]; then
                        (( first == 1 )) || printf ','
                        printf '\n    {"pid": %s, "name": ' "$pid"; blumix_json_quote "$comm"
                        printf ', "state": "PROCESS_DETECTED", "source": "ps -eo pid,comm"}'
                        first=0
                    else
                        printf '[PROCESS_DETECTED] PID %s · %s\n' "$pid" "$comm"
                    fi
                    ;;
            esac
        done < <(ps -eo pid=,comm= 2>/dev/null)
    fi
    if [[ "$mode" == json ]]; then
        printf '\n  ],\n  "services": ['
        first=1
        if blumix_command_exists systemctl; then
            while read -r unit _; do
                [[ -n "$unit" ]] || continue
                case "$unit" in
                    *[Bb][Ll][Uu][Mm][Ii][Xx]*|*[Bb][Ll][Uu][Mm][Cc][Ll]*|*[Bb][Ll][Uu][Mm][Ss][Ee][Cc]*|*[Bb][Ll][Uu][Mm][Ee][Ll][Ii][Xx]*)
                        (( first == 1 )) || printf ','
                        printf '\n    {"name": '; blumix_json_quote "$unit"
                        printf ', "state": "SERVICE_ACTIVE", "source": "systemctl list-units"}'
                        first=0
                        ;;
                esac
            done < <(systemctl --no-legend --plain --type=service --state=active list-units 2>/dev/null || true)
            while read -r unit _; do
                [[ -n "$unit" ]] || continue
                case "$unit" in
                    *[Bb][Ll][Uu][Mm][Ii][Xx]*|*[Bb][Ll][Uu][Mm][Cc][Ll]*|*[Bb][Ll][Uu][Mm][Ss][Ee][Cc]*|*[Bb][Ll][Uu][Mm][Ee][Ll][Ii][Xx]*)
                        (( first == 1 )) || printf ','
                        printf '\n    {"name": '; blumix_json_quote "$unit"
                        printf ', "state": "SERVICE_ACTIVE", "source": "systemctl --user list-units"}'
                        first=0
                        ;;
                esac
            done < <(systemctl --user --no-legend --plain --type=service --state=active list-units 2>/dev/null || true)
        fi
        printf '\n  ],\n  "functional_health": "UNKNOWN",\n  "limitations": "Solo se buscan nombres explícitos de proyectos conocidos; no se prueban endpoints ni procesos con nombres genéricos."\n}\n'
    else
        printf '\n[UNKNOWN] La ausencia de coincidencias no prueba que un servicio esté detenido; no se han supuesto puertos ni endpoints.\n'
    fi
}
