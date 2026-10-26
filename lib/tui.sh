#!/usr/bin/env bash
# BLUMIX ORCHESTRATOR — hierarchical, keyboard-driven terminal interface.
# Read-only local observations; actions delegate to existing BLUMIX commands.

declare -ag BLX_NODE_LABELS BLX_NODE_PARENTS BLX_NODE_ACTIONS BLX_NODE_ICONS
declare -Ag BLX_NODE_EXPANDED
BLX_NODE_LABELS=(
  "BLUMIX ORCHESTRATOR"
  "SYSTEM CORE" "Live telemetry" "Processes and resources"
  "INTELLIGENCE ENGINE" "Evidence diagnostics" "Recommendations"
  "PROJECT ECOSYSTEM" "Project inventory" "Configured paths"
  "OPERATIONS BRANCH" "Service observation" "Local audit"
  "SECURITY BRANCH" "Security posture" "Policy checks"
  "NETWORK BRANCH" "Network and DNS"
  "DEV TOOLCHAIN" "Development tools"
  "EVIDENCE VAULT" "JSON snapshot" "Command reference"
)
BLX_NODE_PARENTS=(-1 0 1 1 0 4 4 0 7 7 0 10 10 0 13 13 0 16 0 18 0 20 20)
BLX_NODE_ACTIONS=(
  intelligence
  system system system
  intelligence intelligence intelligence
  projects projects paths
  services services audit
  security security policy
  network network
  development development
  report report help
)
BLX_NODE_ICONS=(
  "◆" "◈" "◉" "◌" "◈" "◎" "↗" "◈" "▦" "⌖"
  "◈" "⇄" "✓" "◈" "⛨" "⚖" "◈" "⌁" "◈" "⌘"
  "◈" "▤" "?"
)
BLX_NODE_EXPANDED[0]=1

blumix_tui_project_state() {
    local path="$1"
    if [[ ! -d "$path" ]]; then printf 'MISSING'
    elif git -C "$path" rev-parse --git-dir >/dev/null 2>&1; then printf 'GIT DETECTED'
    else printf 'DIRECTORY'; fi
}

blumix_tui_children_count() {
    local parent="$1" i count=0
    for i in "\${!BLX_NODE_PARENTS[@]}"; do
        [[ "\${BLX_NODE_PARENTS[$i]}" == "$parent" ]] && ((count+=1))
    done
    printf '%s' "$count"
}

blumix_tui_render_node() {
    local node="$1" prefix="$2" last="$3" selected="$4"
    local marker="├──" branch="·" color="$BLX_CYAN" i child_prefix="$prefix"
    [[ "$last" == 1 ]] && marker="└──"
    if [[ "$(blumix_tui_children_count "$node")" -gt 0 ]]; then
        if [[ "\${BLX_NODE_EXPANDED[$node]:-0}" == 1 ]]; then branch="▼"; else branch="▶"; fi
    fi
    [[ "$node" == "$selected" ]] && color="$BLX_GREEN"
    printf '%b%s%b %b%s%b %b%-25s%b' "$BLX_DIM" "$prefix$marker" "$BLX_RESET" "$color" "$branch" "$BLX_RESET" "$([[ "$node" == "$selected" ]] && printf '%s' "$BLX_BOLD")" "\${BLX_NODE_LABELS[$node]}" "$BLX_RESET"
    if [[ "$node" == "$selected" ]]; then printf '%b  ◀ ACTIVE%b' "$BLX_GREEN" "$BLX_RESET"; fi
    printf '\\n'
    if [[ "\${BLX_NODE_EXPANDED[$node]:-0}" != 1 ]]; then return; fi
    local -a children=()
    for i in "\${!BLX_NODE_PARENTS[@]}"; do
        [[ "\${BLX_NODE_PARENTS[$i]}" == "$node" ]] && children+=("$i")
    done
    [[ "$last" == 1 ]] && child_prefix+="   " || child_prefix+="│  "
    for i in "\${!children[@]}"; do
        local is_last=0
        (( i == \${#children[@]} - 1 )) && is_last=1
        blumix_tui_render_node "\${children[$i]}" "$child_prefix" "$is_last" "$selected"
    done
}

blumix_tui_render() {
    local selected="$1" width cpu ram disk load mem_total mem_avail i
    local cl sec elx uptime
    width="$(blx_width)"
    cpu="$(blx_cpu_pct 2>/dev/null || printf 0)"
    ram="$(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {if(t>0) printf "%d", (t-a)*100/t}' /proc/meminfo)"
    disk="$(df -P / 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5}')"
    load="$(awk '{print $1}' /proc/loadavg 2>/dev/null)"
    mem_total="$(awk '/^MemTotal:/ {printf "%.1f", $2/1048576}' /proc/meminfo)"
    mem_avail="$(awk '/^MemAvailable:/ {printf "%.1f", $2/1048576}' /proc/meminfo)"
    uptime="$(uptime -p 2>/dev/null | sed 's/^up //')"
    cl="$(blumix_tui_project_state "$BLUMCL_HOME")"
    sec="$(blumix_tui_project_state "$BLUMSEC_HOME")"
    elx="$(blumix_tui_project_state "$BLUMELIX_HOME")"
    [[ "$cpu" =~ ^[0-9]+$ ]] || cpu=0
    [[ "$ram" =~ ^[0-9]+$ ]] || ram=0
    [[ "$disk" =~ ^[0-9]+$ ]] || disk=0
    printf '\\033[H\\033[2J\\033[?25l'
    printf '%b╭' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '╮%b\\n' "$BLX_RESET"
    printf '%b│%b  ◈ BLUMIX ORCHESTRATOR  /  NODE GRAPH & OPERATIONS BUS%*s│%b\\n' "$BLX_CYAN" "$BLX_BOLD" "$((width-57))" "" "$BLX_RESET"
    printf '%b│%b  DOMAIN ROUTING  →  MODULE EXECUTION  →  LOCAL EVIDENCE%*s│%b\\n' "$BLX_CYAN" "$BLX_RESET" "$((width-57))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\\n' "$BLX_RESET"
    printf '%b│%b  HOST %-20.20s  %s%*s│%b\\n' "$BLX_CYAN" "$BLX_BOLD" "$(hostname 2>/dev/null || printf Linux)" "$(date '+%Y-%m-%d %H:%M:%S')" "$((width-57))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\\n' "$BLX_RESET"
    printf '%b│%b  SYSTEM TELEMETRY%*s│%b\\n' "$BLX_CYAN" "$BLX_BOLD" "$((width-19))" "" "$BLX_RESET"
    printf '%b│%b  CPU  ' "$BLX_CYAN" "$BLX_RESET"; blx_bar "$cpu" 12 "$BLX_CYAN"; printf ' %3s%%   RAM ' "$cpu"; blx_bar "$ram" 12 "$BLX_YELLOW"; printf ' %3s%%%*s│%b\\n' "$ram" "$((width-58))" "" "$BLX_RESET"
    printf '%b│%b  DISK ' "$BLX_CYAN" "$BLX_RESET"; blx_bar "$disk" 12 "$BLX_GREEN"; printf ' %3s%%   LOAD %-5s  MEM %s/%s GiB%*s│%b\\n' "$disk" "\${load:-N/D}" "\${mem_total:-?}" "\${mem_avail:-?}" "$((width-58))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\\n' "$BLX_RESET"
    printf '%b│%b  PROJECT SIGNALS  ' "$BLX_CYAN" "$BLX_BOLD"
    printf '%bBLUMCL:%s%b  ' "$([[ "$cl" == "MISSING" ]] && printf '%s' "$BLX_RED" || printf '%s' "$BLX_GREEN")" "$cl" "$BLX_RESET"
    printf '%bBLUMSEC:%s%b  ' "$([[ "$sec" == "MISSING" ]] && printf '%s' "$BLX_RED" || printf '%s' "$BLX_GREEN")" "$sec" "$BLX_RESET"
    printf '%bBLUMELIX:%s%b%*s│%b\\n' "$([[ "$elx" == "MISSING" ]] && printf '%s' "$BLX_RED" || printf '%s' "$BLX_GREEN")" "$elx" "$BLX_RESET" "$((width-68))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\\n' "$BLX_RESET"
    printf '%b│%b  ORCHESTRATION TREE  /  select a node to route into its branch%*s│%b\\n' "$BLX_CYAN" "$BLX_BOLD" "$((width-66))" "" "$BLX_RESET"
    printf '%b│%b  ◆ ROOT   ◈ DOMAIN   ◉ LIVE VIEW   · MODULE%*s│%b\\n' "$BLX_CYAN" "$BLX_RESET" "$((width-49))" "" "$BLX_RESET"
    blumix_tui_render_node 0 "" 1 "$selected"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\\n' "$BLX_RESET"
    printf '%b│%b  ↑↓ select  → expand  ← collapse/parent  Enter route  Space toggle%*s│%b\\n' "$BLX_CYAN" "$BLX_BOLD" "$((width-69))" "" "$BLX_RESET"
    printf '%b│%b  1–8 jump to domain  r refresh  ? help  q exit%*s│%b\\n' "$BLX_CYAN" "$BLX_RESET" "$((width-51))" "" "$BLX_RESET"
    printf '%b╰' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '╯%b\\n' "$BLX_RESET"
}

blumix_tui_node_has_children() {
    [[ "$(blumix_tui_children_count "$1")" -gt 0 ]]
}

blumix_tui_find_parent() {
    printf '%s' "\${BLX_NODE_PARENTS[$1]}"
}

blumix_tui_visible_nodes() {
    local node="$1" i
    BLX_VISIBLE_NODES+=("$node")
    [[ "\${BLX_NODE_EXPANDED[$node]:-0}" == 1 ]] || return
    for i in "\${!BLX_NODE_PARENTS[@]}"; do
        [[ "\${BLX_NODE_PARENTS[$i]}" == "$node" ]] && blumix_tui_visible_nodes "$i"
    done
}

blumix_tui_open() {
    local node="$1" action="\${BLX_NODE_ACTIONS[$1]}"
    printf '\\033[0m\\033[?25h\\033[H\\033[2J'
    case "$action" in
        system) blumix_system ;;
        intelligence) blumix_intelligence ;;
        projects) blumix_projects text ;;
        paths) blumix_paths ;;
        services) blumix_services text ;;
        audit) blumix_audit text ;;
        security) blumix_security ;;
        policy) blumix_policy text ;;
        network) blumix_network ;;
        development) blumix_development ;;
        report) blumix_report_json ;;
        help) blumix_help ;;
        *) printf 'No existe una ruta para el nodo %s.\\n' "\${BLX_NODE_LABELS[$node]}" ;;
    esac
}

blumix_tui_menu() {
    local selected=0 key rest row node parent idx action branch
    local -a BLX_VISIBLE_NODES=()
    [[ -t 0 && -t 1 ]] || { printf 'El orquestador requiere una terminal interactiva. Usa blumix intelligence en modo no interactivo.\\n' >&2; return 2; }
    trap 'printf "\\033[0m\\033[?25h\\n"' EXIT
    while :; do
        BLX_VISIBLE_NODES=()
        blumix_tui_visible_nodes 0
        (( selected >= \${#BLX_VISIBLE_NODES[@]} )) && selected=$(("\${#BLX_VISIBLE_NODES[@]}"-1))
        (( selected < 0 )) && selected=0
        node="\${BLX_VISIBLE_NODES[$selected]}"
        blumix_tui_render "$node"
        key=""
        IFS= read -rsn1 key || break
        action=""
        if [[ "$key" == $'\\033' ]]; then
            rest=""; IFS= read -rsn1 -t 0.15 rest || true
            if [[ "$rest" == "[" ]]; then
                IFS= read -rsn1 -t 0.15 rest || true
                case "$rest" in
                    A) (( selected > 0 )) && selected=$((selected-1)) ;;
                    B) (( selected < \${#BLX_VISIBLE_NODES[@]}-1 )) && selected=$((selected+1)) ;;
                    C) if blumix_tui_node_has_children "$node"; then BLX_NODE_EXPANDED[$node]=1; else action="child"; fi ;;
                    D) if [[ "\${BLX_NODE_EXPANDED[$node]:-0}" == 1 ]] && blumix_tui_node_has_children "$node"; then BLX_NODE_EXPANDED[$node]=0; else parent="$(blumix_tui_find_parent "$node")"; if (( parent >= 0 )); then for idx in "\${!BLX_VISIBLE_NODES[@]}"; do [[ "\${BLX_VISIBLE_NODES[$idx]}" == "$parent" ]] && selected="$idx"; done; fi; fi ;;
                    *) ;;
                esac
            fi
            continue
        fi
        case "$key" in
            q|Q) break ;;
            r|R) continue ;;
            j|J) (( selected < \${#BLX_VISIBLE_NODES[@]}-1 )) && selected=$((selected+1)); continue ;;
            k|K) (( selected > 0 )) && selected=$((selected-1)); continue ;;
            ' ') if blumix_tui_node_has_children "$node"; then if [[ "\${BLX_NODE_EXPANDED[$node]:-0}" == 1 ]]; then BLX_NODE_EXPANDED[$node]=0; else BLX_NODE_EXPANDED[$node]=1; fi; fi; continue ;;
            \?) printf '\\nFLECHAS: ↑/↓ seleccionar · → expandir · ← plegar/volver al padre. Enter abre la ruta del nodo.\\nLas métricas y detecciones son locales; no se realizan cambios automáticos.\\n'; read -r -n 1 -s -p 'Pulsa una tecla para continuar...' || true; continue ;;
            [1-7]) branch=$((10#$key)); selected=0; for idx in "\${!BLX_VISIBLE_NODES[@]}"; do [[ "\${BLX_VISIBLE_NODES[$idx]}" == "$branch" ]] && selected="$idx"; done; continue ;;
            $'\\n'|$'\\r') action="open" ;;
            *) continue ;;
        esac
        if [[ "$action" == "child" ]]; then
            for idx in "\${!BLX_VISIBLE_NODES[@]}"; do
                [[ "\${BLX_NODE_PARENTS[\${BLX_VISIBLE_NODES[$idx]}]}" == "$node" ]] && { selected="$idx"; break; }
            done
        elif [[ "$action" == "open" ]]; then
            blumix_tui_open "$node"
            printf '\\n'
            read -r -n 1 -s -p 'Pulsa una tecla para volver al árbol del orquestador...' || true
        fi
    done
}
