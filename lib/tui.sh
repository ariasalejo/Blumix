#!/usr/bin/env bash
# BLUMIX ORCHESTRATOR — hierarchical, keyboard-driven terminal interface.
# Read-only local observations; actions delegate to existing BLUMIX commands.

declare -ag BLX_NODE_LABELS BLX_NODE_PARENTS BLX_NODE_ACTIONS BLX_NODE_ICONS
declare -Ag BLX_NODE_EXPANDED
BLX_NODE_LABELS=(
  "ORQUESTADOR BLUMIX"
  "NUCLEO DEL SISTEMA" "Telemetria en vivo" "Procesos y recursos"
  "MOTOR DE INTELIGENCIA" "Diagnostico por evidencias" "Recomendaciones accionables"
  "ECOSISTEMA DE PROYECTOS" "Inventario de proyectos" "Rutas configuradas"
  "CENTRO DE OPERACIONES" "Observacion de servicios" "Auditoria local"
  "SEGURIDAD Y POLITICAS" "Postura de seguridad" "Verificacion de politicas"
  "RED Y CONECTIVIDAD" "Red y DNS"
  "FABRICA DE DESARROLLO" "Herramientas de desarrollo"
  "BOVEDA DE EVIDENCIAS" "Instantanea JSON" "Ayuda y comandos"
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
    for i in "${!BLX_NODE_PARENTS[@]}"; do
        [[ "${BLX_NODE_PARENTS[$i]}" == "$parent" ]] && ((count+=1))
    done
    printf '%s' "$count"
}

blumix_tui_render_node() {
    local node="$1" prefix="$2" last="$3" selected="$4"
    local marker="├──" branch="·" color="$BLX_CYAN" i child_prefix="$prefix" glyph
    [[ "$last" == 1 ]] && marker="└──"
    if [[ "$(blumix_tui_children_count "$node")" -gt 0 ]]; then
        if [[ "${BLX_NODE_EXPANDED[$node]:-0}" == 1 ]]; then branch="▼"; else branch="▶"; fi
    fi
    [[ "$node" == "$selected" ]] && color="$BLX_GREEN"
    glyph="${BLX_NODE_ICONS[$node]:-·}"
    printf '%b%s%b %b%s%b %b%s %-32s%b' "$BLX_DIM" "$prefix$marker" "$BLX_RESET" "$color" "$branch" "$BLX_RESET" "$glyph" "$([[ "$node" == "$selected" ]] && printf '%s' "$BLX_BOLD")" "${BLX_NODE_LABELS[$node]}" "$BLX_RESET"
    if [[ "$node" == "$selected" ]]; then printf '%b  ◀ ACTIVE%b' "$BLX_GREEN" "$BLX_RESET"; fi
    printf '\n'
    if [[ "${BLX_NODE_EXPANDED[$node]:-0}" != 1 ]]; then return; fi
    local -a children=()
    for i in "${!BLX_NODE_PARENTS[@]}"; do
        [[ "${BLX_NODE_PARENTS[$i]}" == "$node" ]] && children+=("$i")
    done
    [[ "$last" == 1 ]] && child_prefix+="   " || child_prefix+="│  "
    for i in "${!children[@]}"; do
        local is_last=0
        (( i == ${#children[@]} - 1 )) && is_last=1
        blumix_tui_render_node "${children[$i]}" "$child_prefix" "$is_last" "$selected"
    done
}

blumix_tui_render_card() {
    local node="$1" selected="$2" label icon count badge color marker
    label="${BLX_NODE_LABELS[$node]}"
    icon="${BLX_NODE_ICONS[$node]:-·}"
    count="$(blumix_tui_children_count "$node")"
    color="$BLX_DIM"; marker="  "; badge=""
    if [[ "$node" == "$selected" ]]; then color="$BLX_CYAN"; marker="▌ "; badge="  ◂ EN FOCO"; fi
    if (( count > 0 )); then
        if [[ "${BLX_NODE_EXPANDED[$node]:-0}" == 1 ]]; then badge="${badge}  −"
        else badge="${badge}  +"; fi
    fi
    if [[ "$node" == 0 ]]; then
        printf '%b%s%b %b◈%b  %-23s %b%s%b\n' "$color" "$marker" "$BLX_RESET" "$BLX_MAGENTA" "$BLX_RESET" "Vista general" "$BLX_DIM" "$badge" "$BLX_RESET"
    else
        printf '%b%s%b %b%s%b  %-29s %b%2s módulos%b%s%b\n' "$color" "$marker" "$BLX_RESET" "$BLX_CYAN" "$icon" "$BLX_RESET" "$label" "$BLX_DIM" "$count" "$BLX_RESET" "$badge" "$BLX_RESET"
    fi
}

blumix_tui_selected_description() {
    case "$1" in
        0) printf 'Resumen ejecutivo: telemetría local, integraciones y accesos.' ;;
        1) printf 'Núcleo del sistema: métricas y recursos observables.' ;;
        2) printf 'Telemetría del equipo; datos consultados localmente.' ;;
        3) printf 'Procesos, memoria y recursos visibles para tu usuario.' ;;
        4) printf 'Motor de inteligencia: diagnósticos y recomendaciones.' ;;
        5) printf 'Comprobaciones deterministas basadas en evidencias.' ;;
        6) printf 'Siguientes pasos propuestos a partir de hallazgos.' ;;
        7) printf 'Proyectos separados; no se fusionan repositorios.' ;;
        8) printf 'Inventario de proyectos y estado de detección.' ;;
        9) printf 'Rutas configuradas explícitamente para integraciones.' ;;
        10) printf 'Centro de operaciones: observación y auditoría local.' ;;
        11) printf 'Observa servicios y procesos; no los reinicia.' ;;
        12) printf 'Auditoría local de solo lectura.' ;;
        13) printf 'Señales detectables y límites de seguridad.' ;;
        14) printf 'Postura de seguridad observable del equipo.' ;;
        15) printf 'Políticas, capacidades permitidas y acciones bloqueadas.' ;;
        16) printf 'Red y conectividad: interfaces y resolución DNS.' ;;
        17) printf 'Consulta de red local y DNS.' ;;
        18) printf 'Fábrica de desarrollo: disponibilidad de herramientas.' ;;
        19) printf 'Detección de herramientas de desarrollo instaladas.' ;;
        20) printf 'Bóveda de evidencias: salidas exportables.' ;;
        21) printf 'Instantánea JSON reducida con controles de privacidad.' ;;
        22) printf 'Ayuda de comandos y operaciones disponibles.' ;;
        *) printf 'Módulo BLUMIX.' ;;
    esac
}

blumix_tui_render() {
    local selected="$1" width cpu ram disk load mem_total mem_avail node cl sec elx
    width="$(blx_width)"
    cpu="$(blx_cpu_pct 2>/dev/null || printf 0)"
    ram="$(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {if(t>0) printf "%d", (t-a)*100/t}' /proc/meminfo)"
    disk="$(df -P / 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5}')"
    load="$(awk '{print $1}' /proc/loadavg 2>/dev/null)"
    mem_total="$(awk '/^MemTotal:/ {printf "%.1f", $2/1048576}' /proc/meminfo)"
    mem_avail="$(awk '/^MemAvailable:/ {printf "%.1f", $2/1048576}' /proc/meminfo)"
    cl="$(blumix_tui_project_state "$BLUMCL_HOME")"
    sec="$(blumix_tui_project_state "$BLUMSEC_HOME")"
    elx="$(blumix_tui_project_state "$BLUMELIX_HOME")"
    [[ "$cpu" =~ ^[0-9]+$ ]] || cpu=0
    [[ "$ram" =~ ^[0-9]+$ ]] || ram=0
    [[ "$disk" =~ ^[0-9]+$ ]] || disk=0

    printf '\033[H\033[2J\033[?25l'
    printf '%b╭' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '╮%b\n' "$BLX_RESET"
    printf '%b│%b  ◈ BLUMIX  %bCOMMAND CENTER%b  %bLOCAL · SOLO LECTURA%b%*s│%b\n' "$BLX_CYAN" "$BLX_RESET" "$BLX_BOLD" "$BLX_RESET" "$BLX_GREEN" "$BLX_RESET" "$((width-48))" "" "$BLX_RESET"
    printf '%b│%b  Inteligencia operativa  /  Entender → detectar → verificar → decidir%*s│%b\n' "$BLX_CYAN" "$BLX_DIM" "$((width-72))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\n' "$BLX_RESET"

    printf '%b│%b  SISTEMA  %b%s%b  ·  %s%*s│%b\n' "$BLX_CYAN" "$BLX_BOLD" "$BLX_WHITE" "$(hostname 2>/dev/null || printf Linux)" "$BLX_RESET" "$(date '+%d %b %Y  %H:%M:%S')" "$((width-43))" "" "$BLX_RESET"
    printf '%b│%b  CPU ' "$BLX_CYAN" "$BLX_RESET"; blx_bar "$cpu" 8 "$BLX_CYAN"; printf ' %3s%%   RAM ' "$cpu"; blx_bar "$ram" 8 "$BLX_MAGENTA"; printf ' %3s%%%*s│%b\n' "$ram" "$((width-39))" "" "$BLX_RESET"
    printf '%b│%b  DISCO ' "$BLX_CYAN" "$BLX_RESET"; blx_bar "$disk" 8 "$BLX_GREEN"; printf ' %3s%%   CARGA %-5s  MEM %s/%s GiB%*s│%b\n' "$disk" "${load:-N/D}" "${mem_avail:-?}" "${mem_total:-?}" "$((width-48))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\n' "$BLX_RESET"

    printf '%b│%b  ECOSISTEMA  ' "$BLX_CYAN" "$BLX_BOLD"
    printf '%b● BLUMCL %s%b  ' "$([[ "$cl" == "MISSING" ]] && printf '%s' "$BLX_RED" || printf '%s' "$BLX_GREEN")" "$cl" "$BLX_RESET"
    printf '%b● BLUMSEC %s%b%*s│%b\n' "$([[ "$sec" == "MISSING" ]] && printf '%s' "$BLX_RED" || printf '%s' "$BLX_GREEN")" "$sec" "$BLX_RESET" "$((width-43))" "" "$BLX_RESET"
    printf '%b│%b  %b● BLUMELIX %s%b%*s│%b\n' "$BLX_CYAN" "$BLX_RESET" "$([[ "$elx" == "MISSING" ]] && printf '%s' "$BLX_RED" || printf '%s' "$BLX_GREEN")" "$elx" "$BLX_RESET" "$((width-25))" "" "$BLX_RESET"
    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\n' "$BLX_RESET"

    printf '%b│%b  EXPLORAR BLUMIX  %b·  DOMINIOS Y MÓDULOS%b%*s│%b\n' "$BLX_CYAN" "$BLX_BOLD" "$BLX_DIM" "$BLX_RESET" "$((width-47))" "" "$BLX_RESET"
    printf '%b│%b  Selecciona una sección; expándela para ver sus módulos.%*s│%b\n' "$BLX_CYAN" "$BLX_DIM" "$((width-61))" "" "$BLX_RESET"
    for node in "${BLX_VISIBLE_NODES[@]}"; do blumix_tui_render_card "$node" "$selected"; done

    printf '%b├' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '┤%b\n' "$BLX_RESET"
    printf '%b│%b  %bEN FOCO%b  ' "$BLX_CYAN" "$BLX_RESET" "$BLX_MAGENTA" "$BLX_RESET"
    blumix_tui_selected_description "$selected"
    printf '\n'
    printf '%b│%b  ↑↓ navegar  → abrir sección  ← volver  Enter ejecutar  Espacio expandir%*s│%b\n' "$BLX_CYAN" "$BLX_BOLD" "$((width-70))" "" "$BLX_RESET"
    printf '%b│%b  r actualizar  ? ayuda  q salir%*s│%b\n' "$BLX_CYAN" "$BLX_RESET" "$((width-34))" "" "$BLX_RESET"
    printf '%b╰' "$BLX_CYAN"; printf '─%.0s' $(seq 1 "$width"); printf '╯%b\n' "$BLX_RESET"
}

blumix_tui_node_has_children() {
    [[ "$(blumix_tui_children_count "$1")" -gt 0 ]]
}

blumix_tui_find_parent() {
    printf '%s' "${BLX_NODE_PARENTS[$1]}"
}

blumix_tui_visible_nodes() {
    local node="$1" i
    BLX_VISIBLE_NODES+=("$node")
    [[ "${BLX_NODE_EXPANDED[$node]:-0}" == 1 ]] || return
    for i in "${!BLX_NODE_PARENTS[@]}"; do
        [[ "${BLX_NODE_PARENTS[$i]}" == "$node" ]] && blumix_tui_visible_nodes "$i"
    done
}

blumix_tui_open() {
    local node="$1" action="${BLX_NODE_ACTIONS[$1]}"
    printf '\033[0m\033[?25h\033[H\033[2J'
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
        *) printf 'No existe una ruta para el nodo %s.\n' "${BLX_NODE_LABELS[$node]}" ;;
    esac
}

blumix_tui_menu() {
    local selected=0 key rest row node parent idx action branch
    local -a BLX_VISIBLE_NODES=()
    [[ -t 0 && -t 1 ]] || { printf 'El orquestador requiere una terminal interactiva. Usa blumix intelligence en modo no interactivo.\n' >&2; return 2; }
    trap 'printf "\033[0m\033[?25h\n"' EXIT
    while :; do
        BLX_VISIBLE_NODES=()
        blumix_tui_visible_nodes 0
        (( selected >= ${#BLX_VISIBLE_NODES[@]} )) && selected=$(("${#BLX_VISIBLE_NODES[@]}"-1))
        (( selected < 0 )) && selected=0
        node="${BLX_VISIBLE_NODES[$selected]}"
        blumix_tui_render "$node"
        key=""
        IFS= read -rsn1 key || break
        action=""
        if [[ "$key" == $'\033' ]]; then
            rest=""; IFS= read -rsn1 -t 0.15 rest || true
            if [[ "$rest" == "[" ]]; then
                IFS= read -rsn1 -t 0.15 rest || true
                case "$rest" in
                    A) (( selected > 0 )) && selected=$((selected-1)) ;;
                    B) (( selected < ${#BLX_VISIBLE_NODES[@]}-1 )) && selected=$((selected+1)) ;;
                    C) if blumix_tui_node_has_children "$node"; then BLX_NODE_EXPANDED[$node]=1; else action="child"; fi ;;
                    D) if [[ "${BLX_NODE_EXPANDED[$node]:-0}" == 1 ]] && blumix_tui_node_has_children "$node"; then BLX_NODE_EXPANDED[$node]=0; else parent="$(blumix_tui_find_parent "$node")"; if (( parent >= 0 )); then for idx in "${!BLX_VISIBLE_NODES[@]}"; do [[ "${BLX_VISIBLE_NODES[$idx]}" == "$parent" ]] && selected="$idx"; done; fi; fi ;;
                    *) ;;
                esac
            fi
            continue
        fi
        case "$key" in
            q|Q) break ;;
            r|R) continue ;;
            j|J) (( selected < ${#BLX_VISIBLE_NODES[@]}-1 )) && selected=$((selected+1)); continue ;;
            k|K) (( selected > 0 )) && selected=$((selected-1)); continue ;;
            ' ') if blumix_tui_node_has_children "$node"; then if [[ "${BLX_NODE_EXPANDED[$node]:-0}" == 1 ]]; then BLX_NODE_EXPANDED[$node]=0; else BLX_NODE_EXPANDED[$node]=1; fi; fi; continue ;;
            \?) printf '\nFLECHAS: ↑/↓ seleccionar · → expandir · ← plegar/volver al padre. Enter abre la ruta del nodo.\nLas métricas y detecciones son locales; no se realizan cambios automáticos.\n'; read -r -n 1 -s -p 'Pulsa una tecla para continuar...' || true; continue ;;
            [1-7]) branch=$((10#$key)); selected=0; for idx in "${!BLX_VISIBLE_NODES[@]}"; do [[ "${BLX_VISIBLE_NODES[$idx]}" == "$branch" ]] && selected="$idx"; done; continue ;;
            $'\n'|$'\\r') action="open" ;;
            *) continue ;;
        esac
        if [[ "$action" == "child" ]]; then
            for idx in "${!BLX_VISIBLE_NODES[@]}"; do
                [[ "${BLX_NODE_PARENTS[${BLX_VISIBLE_NODES[$idx]}]}" == "$node" ]] && { selected="$idx"; break; }
            done
        elif [[ "$action" == "open" ]]; then
            blumix_tui_open "$node"
            printf '\n'
            read -r -n 1 -s -p 'Pulsa una tecla para volver al árbol del orquestador...' || true
        fi
    done
}
