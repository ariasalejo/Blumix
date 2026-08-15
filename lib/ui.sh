#!/usr/bin/env bash
# BLUMIX · UI ULTRA-CYBER

BLX_RESET=$'\033[0m';  BLX_BOLD=$'\033[1m'; BLX_DIM=$'\033[2m'
BLX_CYAN=$'\033[1;36m'; BLX_BLUE=$'\033[1;34m'; BLX_GREEN=$'\033[1;32m'
BLX_YELLOW=$'\033[1;33m'; BLX_RED=$'\033[1;31m'; BLX_WHITE=$'\033[1;37m'
BLX_MAGENTA=$'\033[1;35m'

blx_cols() { local c; c="$(tput cols 2>/dev/null || echo 80)"; [[ "$c" =~ ^[0-9]+$ ]] || c=80; echo "$c"; }
blx_width() { local w=$(( $(blx_cols) - 4 )); (( w > 76 )) && w=76; (( w < 40 )) && w=40; echo "$w"; }

blx_center() {
    local text="$1" width=$(blx_cols) len=${#text} pad=$(( (width-len)/2 ))
    (( pad < 0 )) && pad=0
    printf '%*s%b\n' "$pad" '' "$text"
}

# ── Lluvia Matrix (burst corto) ──
blx_matrix() {
    [[ "${BLUMIX_ANIM:-1}" == "0" ]] && return; [[ -t 1 ]] || return
    local cols=$(blx_cols) rows=5 f i j line
    local chars='01<>*+=-/\:'
    for ((f=0; f<5; f++)); do
        for ((i=0;i<rows;i++)); do
            line=""
            for ((j=0;j<cols;j++)); do line+="${chars:RANDOM%${#chars}:1}"; done
            printf '%b%s%b\n' "$BLX_DIM" "$line" "$BLX_RESET"
        done
        printf '%b' "\033[${rows}A"
        sleep 0.05
    done
    printf '%b' "\033[${rows}A\033[J"
}

# ── Glitch de título ──
blx_glitch() {
    local text="$1" i
    local cols=("$BLX_RED" "$BLX_MAGENTA" "$BLX_CYAN")
    for i in 0 1 2; do
        printf '\r%b%s%b' "${cols[$i]}" "$text" "$BLX_RESET"; sleep 0.06
    done
    printf '\r%b%s%b\n' "$BLX_CYAN" "$text" "$BLX_RESET"
}

# ── Efecto de tipeo ──
blx_typing() {
    local text="$1" i
    for ((i=0;i<${#text};i++)); do
        printf '%b%s%b' "$BLX_GREEN" "${text:i:1}" "$BLX_RESET"; sleep 0.012
    done
    printf '\n'
}

# ── Spinner de escaneo ──
blx_spin() {
    local frames='|/-\' i
    for ((i=0;i<8;i++)); do
        printf '\r%b%s%b %s' "$BLX_CYAN" "${frames:i%4:1}" "$BLX_RESET" "$1"; sleep 0.06
    done
    printf '\r%b[✓]%b %s\n' "$BLX_GREEN" "$BLX_RESET" "$1"
}

# ── Barra neón ──
blx_bar() {
    local pct=$1 width=${2:-16} color=${3:-$BLX_GREEN}
    (( pct < 0 )) && pct=0; (( pct > 100 )) && pct=100
    local filled=$(( pct*width/100 )) empty=$(( width-filled )) bar="" i
    for ((i=0;i<filled;i++)); do bar+="█"; done
    for ((i=0;i<empty;i++));  do bar+="░"; done
    printf '%b[%s]%b' "$color" "$bar" "$BLX_RESET"
}

# ── CPU % real ──
blx_cpu_pct() {
    local a=($(head -1 /proc/stat)) t1=0 i1=${a[4]} v
    for v in "${a[@]:1}"; do t1=$((t1+v)); done
    sleep 0.3
    local b=($(head -1 /proc/stat)) t2=0 i2=${b[4]}
    for v in "${b[@]:1}"; do t2=$((t2+v)); done
    local dt=$((t2-t1)) di=$((i2-i1))
    (( dt == 0 )) && { echo 0; return; }
    echo $(( (dt-di)*100/dt ))
}

# ── ASCII art con encendido línea a línea ──
blx_ascii_art() {
    local colors=("$BLX_CYAN" "$BLX_BLUE" "$BLX_MAGENTA" "$BLX_MAGENTA" "$BLX_YELLOW" "$BLX_GREEN")
    local art=(
        "██████╗ ██╗     ██╗   ██╗███╗   ███╗██╗██╗  ██╗"
        "██╔══██╗██║     ██║   ██║████╗ ████║██║╚██╗██╔╝"
        "██████╔╝██║     ██║   ██║██╔████╔██║██║ ╚███╔╝ "
        "██╔══██╗██║     ██║   ██║██║╚██╔╝██║██║ ██╔██╗ "
        "██████╔╝███████╗╚██████╝██║ ╚═╝ ██║██║██╔╝ ██╗"
        "╚═════╝ ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝═╝  ╚═╝"
    )
    local aw=${#art[0]} term=$(blx_cols) pad=$(( (term-aw)/2 )) i
    (( pad < 0 )) && pad=0
    printf '\n'
    for i in "${!art[@]}"; do
        printf '%b%*s%s%b\n' "${colors[$i]}" "$pad" '' "${art[$i]}" "$BLX_RESET"
        [[ "${BLUMIX_ANIM:-1}" != "0" ]] && sleep 0.05
    done
    printf '\n'
}

# ── HUD holográfico con barras ──
blx_hud() {
    local w=$(blx_width)
    local cpu=$(blx_cpu_pct)
    local ram=$(free 2>/dev/null | awk '/^Mem:/ {printf "%.0f", ($3/$2)*100}')
    local disk=$(df -h / 2>/dev/null | awk 'NR==2 {gsub("%","",$5); print $5}')
    local bat=""
    command -v upower >/dev/null 2>&1 && bat=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | grep percentage | awk '{gsub("%","",$2); print $2}')

    printf '%b╔═[%b HUD VITAL %b]%b' "$BLX_CYAN" "$BLX_BOLD" "$BLX_RESET" "$BLX_CYAN"
    printf '═%.0s' $(seq 1 $((w-15))); printf '╗%b\n' "$BLX_RESET"
    printf '%b║%b ⚡ CPU  ' "$BLX_CYAN" "$BLX_RESET"; blx_bar "$cpu" 14 "$BLX_RED";    printf ' %b%3s%%%b\n' "$BLX_RED" "$cpu" "$BLX_RESET"
    printf '%b║%b 🧠 RAM  ' "$BLX_CYAN" "$BLX_RESET"; blx_bar "${ram:-0}" 14 "$BLX_YELLOW"; printf ' %b%3s%%%b\n' "$BLX_YELLOW" "${ram:-?}" "$BLX_RESET"
    printf '%b║%b 💾 DISK ' "$BLX_CYAN" "$BLX_RESET"; blx_bar "${disk:-0}" 14 "$BLX_GREEN"; printf ' %b%3s%%%b\n' "$BLX_GREEN" "${disk:-?}" "$BLX_RESET"
    if [[ -n "$bat" ]]; then
        local bc=$BLX_GREEN; (( bat<=20 )) && bc=$BLX_RED; (( bat<=50 )) && bc=$BLX_YELLOW
        printf '%b║%b 🔋 BAT  ' "$BLX_CYAN" "$BLX_RESET"; blx_bar "$bat" 14 "$bc"; printf ' %b%3s%%%b\n' "$bc" "$bat" "$BLX_RESET"
    fi
    printf '%b╚' "$BLX_CYAN"; printf '═%.0s' $(seq 1 $w); printf '╝%b\n' "$BLX_RESET"
    printf '\n'
}

# ── Funciones básicas (módulos) ──
blx_logo(){ blx_ascii_art; }
blx_title() {
    local w=$(blx_width)
    printf '%b╔' "$BLX_CYAN"; printf '═%.0s' $(seq 1 $w); printf '╗\n'
    printf '║%b %s%b\n' "$BLX_BOLD" "$1" "$BLX_RESET"
    printf '%b╚' "$BLX_CYAN"; printf '═%.0s' $(seq 1 $w); printf '╝%b\n' "$BLX_RESET"
}
blx_row(){ printf '  %b%s%b\n' "$BLX_GREEN" "$1" "$BLX_RESET"; }
blx_warn(){ printf '  %b%s%b\n' "$BLX_YELLOW" "$1" "$BLX_RESET"; }
blx_err(){ printf '  %b%s%b\n' "$BLX_RED" "$1" "$BLX_RESET"; }
blx_bottom(){ printf '\n'; }
blx_menu(){ printf '%bComandos:%b\n' "$BLX_BOLD" "$BLX_RESET"; }
