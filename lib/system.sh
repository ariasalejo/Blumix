#!/usr/bin/env bash
blumix_system() {
    blx_title "🖥️  SISTEMA"
    blx_row "OS: $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME")"
    blx_row "Host: $(hostname)"
    blx_row "Kernel: $(uname -r)"
    blx_row "Uptime: $(uptime -p 2>/dev/null || uptime | sed 's/.*up //' | sed 's/,.*//')"
    blx_row "RAM: $(free -h | awk '/^Mem:/ {printf "%s / %s", $3, $2}')"
    blx_row "CPU: $(lscpu 2>/dev/null | grep 'Model name' | cut -d: -f2 | xargs)"
    blx_bottom
}
