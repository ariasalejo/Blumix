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

blumix_tui_open() {
    case "$1" in
        0) blumix_system ;;
        1) blumix_intelligence ;;
        2) blumix_projects text ;;
        3) blumix_services text ;;
        4) blumix_audit text ;;
        5) blumix_security ;;
        6) blumix_network ;;
        7) blumix_development ;;
        8) blumix_paths ;;
        9) blumix_help ;;
    esac
}
blumix_tui_menu() {
    local selected=0 key rest action
    [[ -t 0 && -t 1 ]] || { printf 'El centro interactivo requiere una terminal; usa blumix intelligence fuera de ella.\n' >&2; return 2; }
    command -v ps >/dev/null 2>&1 || { printf 'Falta ps; instala procps para usar el centro visual.\n' >&2; return 2; }
    trap 'printf "\033[0m\033[?25h\n"' EXIT
    while :; do
        blumix_tui_render "$selected"
        key=""
        IFS= read -rsn1 key || break
        if [[ "$key" == $'\033' ]]; then
            rest=""
            IFS= read -rsn1 -t 0.15 rest || true
            if [[ "$rest" == "[" ]]; then
                IFS= read -rsn1 -t 0.15 rest || true
                case "$rest" in
                    A|D) (( selected > 0 )) && selected=$((selected-1)) ;;
                    B|C) (( selected < 9 )) && selected=$((selected+1)) ;;
                    H) selected=0 ;;
                    F) selected=9 ;;
                esac
            fi
            continue
        fi
        action=""
        case "$key" in
            q|Q) break ;;
            r|R) continue ;;
            j|J) (( selected < 9 )) && selected=$((selected+1)); continue ;;
            k|K) (( selected > 0 )) && selected=$((selected-1)); continue ;;
            \?) action="help" ;;
            [1-9]) selected=$((10#$key-1)); action="open" ;;
            0) break ;;
            ""|$'\n'|$'\r') action="open" ;;
            *) continue ;;
        esac
        if [[ "$action" == "help" ]]; then
            printf '\nNAVEGACIÓN: flechas arriba/abajo o j/k · Enter abre · 1–9 acceso directo · r refresca · q sale.\n'
            printf 'Los diagnósticos son locales y de solo lectura. Las rutas no prueban salud funcional.\n'
            read -r -n 1 -s -p 'Pulsa una tecla para continuar...' || true
        elif [[ "$action" == "open" ]]; then
            printf '\033[0m\033[?25h\033[H\033[2J'
            blumix_tui_open "$selected"
            printf '\n'
            read -r -n 1 -s -p 'Pulsa una tecla para volver al centro de mando...' || true
        fi
    done
}
