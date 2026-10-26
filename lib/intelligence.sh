#!/usr/bin/env bash
# BLUMIX Intelligence Center: reglas deterministas, evidencia local y solo lectura.
# No es IA predictiva ni ejecuta acciones correctivas.
blumix_intelligence() {
    local cpu ram_used ram_total ram_available ram_pct available_pct disk_pct
    local cores load1 load_per_core state="OPERATIVO" severity=0 findings=0
    local path name found=0 total=0
    local mem_total_kb mem_available_kb mem_used_kb
    local -a advice=()

    cpu="$(blx_cpu_pct 2>/dev/null || true)"
    [[ "$cpu" =~ ^[0-9]+$ ]] || cpu=""
    mem_total_kb="$(awk '/^MemTotal:/ {print $2; exit}' /proc/meminfo 2>/dev/null)"
    mem_available_kb="$(awk '/^MemAvailable:/ {print $2; exit}' /proc/meminfo 2>/dev/null)"
    if [[ "$mem_total_kb" =~ ^[0-9]+$ && "$mem_available_kb" =~ ^[0-9]+$ ]] && (( mem_total_kb > 0 )); then
        (( mem_available_kb > mem_total_kb )) && mem_available_kb=$mem_total_kb
        mem_used_kb=$((mem_total_kb - mem_available_kb))
        ram_pct=$((mem_used_kb * 100 / mem_total_kb))
        available_pct=$((mem_available_kb * 100 / mem_total_kb))
        ram_used="$(awk -v k="$mem_used_kb" 'BEGIN {printf "%.1f GiB", k/1048576}')"
        ram_total="$(awk -v k="$mem_total_kb" 'BEGIN {printf "%.1f GiB", k/1048576}')"
        ram_available="$(awk -v k="$mem_available_kb" 'BEGIN {printf "%.1f GiB", k/1048576}')"
    else
        ram_pct=""; available_pct=""; ram_used="N/D"; ram_total="N/D"; ram_available="N/D"
    fi
    disk_pct="$(df -P / 2>/dev/null | awk 'NR==2 {gsub(/%/, "", $5); print $5}')"
    [[ "$disk_pct" =~ ^[0-9]+$ ]] || disk_pct=""
    cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1')"
    [[ "$cores" =~ ^[0-9]+$ ]] && (( cores > 0 )) || cores=1
    load1="$(awk '{print $1}' /proc/loadavg 2>/dev/null)"
    [[ -n "$load1" ]] || load1="N/D"
    if [[ "$load1" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        load_per_core="$(awk -v l="$load1" -v c="$cores" 'BEGIN {printf "%.2f", l/c}')"
    else
        load_per_core="N/D"
    fi

    blx_title "CENTRO DE INTELIGENCIA — DIAGNÓSTICO ACCIONABLE"
    printf '  Evidencia local · reglas deterministas · solo lectura · %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || printf 'hora N/D')"
    printf '  %-23s %s\n' "CPU (muestra breve):" "${cpu:-N/D}${cpu:+%}"
    printf '  %-23s %s usados / %s · %s disponible\n' "Memoria:" "$ram_used" "$ram_total" "$ram_available"
    printf '  %-23s %s%% usado\n' "Disco raíz:" "${disk_pct:-N/D}"
    printf '  %-23s %s núcleos · carga 1 min %s (%s por núcleo)\n' "Carga del sistema:" "$cores" "$load1" "$load_per_core"

    if [[ "$cpu" =~ ^[0-9]+$ ]]; then
        if (( cpu >= 90 )); then
            severity=2; findings=$((findings+1))
            advice+=("CPU muy alta: inspecciona los procesos que más CPU usan con: ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 8")
        elif (( cpu >= 75 )); then
            (( severity < 1 )) && severity=1; findings=$((findings+1))
            advice+=("CPU elevada: compara una segunda muestra antes de concluir que existe un problema.")
        fi
    fi
    if [[ "$available_pct" =~ ^[0-9]+$ ]]; then
        if (( available_pct < 8 )); then
            severity=2; findings=$((findings+1))
            advice+=("Memoria disponible muy baja: revisa procesos con ps -eo pid,comm,%mem,rss --sort=-%mem | head -n 8")
        elif (( available_pct < 15 )); then
            (( severity < 1 )) && severity=1; findings=$((findings+1))
            advice+=("Memoria disponible reducida: revisa tendencia y aplicaciones abiertas; no mates procesos automáticamente.")
        fi
    fi
    if [[ "$disk_pct" =~ ^[0-9]+$ ]]; then
        if (( disk_pct >= 95 )); then
            severity=2; findings=$((findings+1))
            advice+=("Disco raíz casi lleno: localiza el consumo con du -xhd1 "$HOME" 2>/dev/null | sort -h; no borres archivos sin revisarlos.")
        elif (( disk_pct >= 85 )); then
            (( severity < 1 )) && severity=1; findings=$((findings+1))
            advice+=("Espacio de disco en observación: revisa los directorios grandes antes de limpiar.")
        fi
    fi

    printf '\n  INTEGRIDAD DEL ECOSISTEMA\n'
    for name in BLUMCL BLUMSEC BLUMELIX; do
        case "$name" in
            BLUMCL) path="$BLUMCL_HOME" ;;
            BLUMSEC) path="$BLUMSEC_HOME" ;;
            BLUMELIX) path="$BLUMELIX_HOME" ;;
        esac
        total=$((total+1))
        if [[ -d "$path" ]]; then
            found=$((found+1))
            if [[ -d "$path/.git" || -f "$path/.git" ]]; then
                printf '  [OK]       %s · carpeta y metadatos Git detectados\n' "$name"
            else
                printf '  [PARCIAL]  %s · carpeta presente; no se detectan metadatos Git en la raíz\n' "$name"
                (( severity < 1 )) && severity=1
                findings=$((findings+1))
            fi
        else
            printf '  [FALTA]    %s · ruta configurada: %s\n' "$name" "$path"
            (( severity < 1 )) && severity=1
            findings=$((findings+1))
            if [[ "$name" == "BLUMELIX" ]]; then
                advice+=("BLUMELIX no se ha localizado en la ruta configurada. Busca primero sin modificar nada: find "$HOME/04_DEVELOPMENT/08_Proyectos/Blum" -maxdepth 2 -type d -iname '*blumelix*' -o -iname '*blumix*' 2>/dev/null")
            fi
        fi
    done

    printf '\n  HERRAMIENTAS CLAVE\n'
    local tool
    for tool in git python3 node npm opencode qwen ollama shellcheck; do
        if blumix_command_exists "$tool"; then
            printf '  [DISPONIBLE] %s\n' "$tool"
        else
            printf '  [NO DETECTADA] %s\n' "$tool"
        fi
    done

    case "$severity" in
        2) state="ATENCIÓN PRIORITARIA" ;;
        1) state="REVISAR" ;;
        *) state="SIN ALERTAS POR UMBRAL" ;;
    esac
    printf '\n  ESTADO: %s · %s hallazgo(s) por reglas locales\n' "$state" "$findings"
    if (("${#advice[@]}" > 0)); then
        printf '\n  SIGUIENTES PASOS SUGERIDOS (no ejecutados)\n'
        local item
        for item in "${advice[@]}"; do printf '  • %s\n' "$item"; done
    else
        printf '\n  No se activaron umbrales de alerta. Esto no demuestra ausencia de fallos.\n'
    fi
    printf '\n  Límites: no identifica causas por sí solo, no consulta Internet, no eleva privilegios, no cambia servicios ni archivos.\n'
}
