#!/usr/bin/env bash
# BLUMIX terminal dashboard helpers.
blumix_tui_project_state() {
    local path="$1"
    if [[ ! -d "$path" ]]; then printf 'MISSING'
    elif git -C "$path" rev-parse --git-dir >/dev/null 2>&1; then printf 'GIT DETECTED'
    else printf 'DIRECTORY'; fi
}
blumix_tui_render() {
    local selected="$1" cpu ram disk load width i
    local -a labels=("System overview" "Intelligence diagnostics" "Project inventory" "Service observation" "Local audit" "Security" "Network and DNS" "Development tools" "Configured paths" "Help")
    width="$(blx_width)"
    cpu="$(blx_cpu_pct 2>/dev/null || printf 0)"
    ram="$(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {if(t>0) printf "%d", (t-a)*100/t}' /proc/meminfo)"
    disk="$(df -P / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')"
    load="$(awk '{print $1}' /proc/loadavg)"
    printf '\033[H\033[2J\033[?25l'
    printf '%b╭' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '╮%b\n' "$BLX_RESET"
    printf '%b│%b  BLUMIX  /  INTELLIGENCE CONSOLE%*s│%b\n' "$BLX_CYAN" "$BLX_BOLD" "$((width-34))" "" "$BLX_RESET"
    printf '%b│%b  LOCAL TELEMETRY · EVIDENCE-BASED · READ-ONLY BY DEFAULT%*s│%b\n' "$BLX_CYAN" "$BLX_RESET" "$((width-58))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\n' "$BLX_RESET"
    printf '%b│%b  HOST %-20.20s  %s%*s│%b\n' "$BLX_CYAN" "$BLX_BOLD" "$(hostname)" "$(date '+%Y-%m-%d %H:%M:%S')" "$((width-57))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\n' "$BLX_RESET"
    printf '%b│%b  CPU  ' "$BLX_CYAN" "$BLX_RESET"; blx_bar "$cpu" 16 "$BLX_CYAN"
    printf ' %3s%%   RAM  ' "$cpu"; blx_bar "$ram" 16 "$BLX_YELLOW"; printf ' %3s%%%*s│%b\n' "$ram" "$((width-55))" "" "$BLX_RESET"
    printf '%b│%b  DISK ' "$BLX_CYAN" "$BLX_RESET"; blx_bar "$disk" 16 "$BLX_GREEN"
    printf ' %3s%%   LOAD %s%*s│%b\n' "$disk" "$load" "$((width-42))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\n' "$BLX_RESET"
    printf '%b│%b  PROJECT ECOSYSTEM%*s│%b\n' "$BLX_CYAN" "$BLX_BOLD" "$((width-20))" "" "$BLX_RESET"
    printf '%b│%b  BLUMCL   %-14s  BLUMSEC   %-14s%*s│%b\n' "$BLX_CYAN" "$BLX_RESET" "$(blumix_tui_project_state "$BLUMCL_HOME")" "$(blumix_tui_project_state "$BLUMSEC_HOME")" "$((width-62))" "" "$BLX_RESET"
    printf '%b│%b  BLUMELIX %-14s%*s│%b\n' "$BLX_CYAN" "$BLX_RESET" "$(blumix_tui_project_state "$BLUMELIX_HOME")" "$((width-28))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\n' "$BLX_RESET"
    printf '%b│%b  OPERATIONS · arrows select · Enter open · 1–9 direct · q quit%*s│%b\n' "$BLX_CYAN" "$BLX_BOLD" "$((width-64))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\n' "$BLX_RESET"
    for i in "${!labels[@]}"; do
        if (( i == selected )); then
            printf '%b│%b  %b▶ %-2s %-36s%b%*s│%b\n' "$BLX_CYAN" "$BLX_RESET" "$BLX_BOLD$BLX_CYAN" "$((i+1))" "${labels[$i]}" "$BLX_RESET" "$((width-46))" "" "$BLX_RESET"
        else
            printf '%b│%b    %-2s %-36s%*s│%b\n' "$BLX_CYAN" "$BLX_RESET" "$((i+1))" "${labels[$i]}" "$((width-43))" "" "$BLX_RESET"
        fi
    done
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\n' "$BLX_RESET"
    printf '%b│%b  r refresh · ? help · q exit · directory presence is not service health%*s│%b\n' "$BLX_CYAN" "$BLX_RESET" "$((width-76))" "" "$BLX_RESET"
    printf '%b╰' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '╯%b\n' "$BLX_RESET"
}
