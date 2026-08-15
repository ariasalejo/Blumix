#!/usr/bin/env bash
BLX_RESET=$'\033[0m'; BLX_BOLD=$'\033[1m'; BLX_CYAN=$'\033[1;36m'; BLX_GREEN=$'\033[1;32m'
blx_title() { printf '\n%b%s%b\n' "$BLX_BOLD" "$BLX_CYAN$1" "$BLX_RESET"; }
blx_row() { printf '  %b%s%b\n' "$BLX_GREEN" "$1" "$BLX_RESET"; }
blx_bottom() { printf '\n'; }
