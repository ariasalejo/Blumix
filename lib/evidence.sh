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


blumix_intelligence_json() {
    local generated cpu mem_total mem_available mem_pct disk_pct load1 cores
    local cpu_json mem_json disk_json load_json state="OBSERVED"
    generated="$(date -Is 2>/dev/null || date -u '+%Y-%m-%dT%H:%M:%SZ')"
    cpu="$(blx_cpu_pct 2>/dev/null || true)"
    [[ "$cpu" =~ ^[0-9]+$ ]] || cpu=""
    mem_total="$(awk '/^MemTotal:/ {print $2; exit}' /proc/meminfo 2>/dev/null)"
    mem_available="$(awk '/^MemAvailable:/ {print $2; exit}' /proc/meminfo 2>/dev/null)"
    mem_pct=""
    if [[ "$mem_total" =~ ^[0-9]+$ && "$mem_available" =~ ^[0-9]+$ ]] && (( mem_total > 0 )); then
        (( mem_available > mem_total )) && mem_available=$mem_total
        mem_pct=$(((mem_total - mem_available) * 100 / mem_total))
    fi
    disk_pct="$(df -P / 2>/dev/null | awk 'NR==2 {gsub(/%/, "", $5); print $5}')"
    [[ "$disk_pct" =~ ^[0-9]+$ ]] || disk_pct=""
    load1="$(awk '{print $1}' /proc/loadavg 2>/dev/null)"
    [[ "$load1" =~ ^[0-9]+([.][0-9]+)?$ ]] || load1=""
    cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null)"
    [[ "$cores" =~ ^[0-9]+$ && "$cores" -gt 0 ]] || cores=""
    if { [[ "$cpu" =~ ^[0-9]+$ ]] && (( cpu >= 90 )); } ||
       { [[ "$mem_pct" =~ ^[0-9]+$ ]] && (( mem_pct >= 92 )); } ||
       { [[ "$disk_pct" =~ ^[0-9]+$ ]] && (( disk_pct >= 95 )); }; then
        state="DEGRADED"
    elif { [[ "$cpu" =~ ^[0-9]+$ ]] && (( cpu >= 75 )); } ||
         { [[ "$mem_pct" =~ ^[0-9]+$ ]] && (( mem_pct >= 85 )); } ||
         { [[ "$disk_pct" =~ ^[0-9]+$ ]] && (( disk_pct >= 85 )); }; then
        state="REVIEW"
    fi
    [[ "$cpu" =~ ^[0-9]+$ ]] && cpu_json="$cpu" || cpu_json=null
    [[ "$mem_pct" =~ ^[0-9]+$ ]] && mem_json="$mem_pct" || mem_json=null
    [[ "$disk_pct" =~ ^[0-9]+$ ]] && disk_json="$disk_pct" || disk_json=null
    [[ -n "$load1" ]] && load_json="$(blumix_json_quote "$load1")" || load_json=null
    printf '{\n  "schema": "blumix.intelligence.v1",\n  "generated_at": '
    blumix_json_quote "$generated"
    printf ',\n  "state": '; blumix_json_quote "$state"
    printf ',\n  "metrics": {"cpu_percent": %s, "memory_used_percent": %s, "root_disk_used_percent": %s, "load_1m": %s, "logical_cores": ' "$cpu_json" "$mem_json" "$disk_json" "$load_json"
    [[ -n "$cores" ]] && printf '%s' "$cores" || printf 'null'
    printf '},\n  "checks": ['
    printf '\n    {"id": "cpu", "status": '; if [[ "$cpu" =~ ^[0-9]+$ ]]; then if (( cpu >= 90 )); then printf '"DEGRADED"'; elif (( cpu >= 75 )); then printf '"REVIEW"'; else printf '"OBSERVED"'; fi; else printf '"UNKNOWN"'; fi
    printf ', "source": "CPU sample", "checked_at": '; blumix_json_quote "$generated"; printf ', "limitations": "Muestra breve; no identifica causa raíz."},'
    printf '\n    {"id": "memory", "status": '; if [[ "$mem_pct" =~ ^[0-9]+$ ]]; then if (( mem_pct >= 92 )); then printf '"DEGRADED"'; elif (( mem_pct >= 85 )); then printf '"REVIEW"'; else printf '"OBSERVED"'; fi; else printf '"UNKNOWN"'; fi
    printf ', "source": "/proc/meminfo MemAvailable", "checked_at": '; blumix_json_quote "$generated"; printf '},'
    printf '\n    {"id": "root_disk", "status": '; if [[ "$disk_pct" =~ ^[0-9]+$ ]]; then if (( disk_pct >= 95 )); then printf '"DEGRADED"'; elif (( disk_pct >= 85 )); then printf '"REVIEW"'; else printf '"OBSERVED"'; fi; else printf '"UNKNOWN"'; fi
    printf ', "source": "df -P /", "checked_at": '; blumix_json_quote "$generated"; printf '}'
    printf '\n  ],\n  "safety": {"read_only": true, "network_access": false, "secrets_included": false, "service_health_checked": false}\n}\n'
}
