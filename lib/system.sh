#!/usr/bin/env bash
blumix_system() {
    blx_title "🖥️  SISTEMA"
    blx_row "OS: $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME")"
    blx_row "Host: $(hostname)"
    blx_row "Kernel: $(uname -r)"
    blx_row "Uptime: $(uptime -p 2>/dev/null || uptime | sed 's/.*up //' | sed 's/,.*//')"
    blx_row "RAM: $(free -h | awk '/^Mem:/ {printf "%s / %s", $3, $2}')"
    local cpu_model
    cpu_model="$(lscpu 2>/dev/null | awk -F: '/Model name|Nombre del modelo/ {gsub(/^[[:space:]]+/, "", $2); if ($2 != "") {print $2; exit}}')"
    if [[ -z "$cpu_model" ]]; then
        cpu_model="$(awk -F: '/model name/ {gsub(/^[[:space:]]+/, "", $2); if ($2 != "") {print $2; exit}}' /proc/cpuinfo 2>/dev/null)"
    fi
    [[ -n "$cpu_model" ]] || cpu_model="No disponible en este entorno"
    blx_row "CPU: $cpu_model"
    blx_bottom
}
