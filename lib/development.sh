#!/usr/bin/env bash
blumix_development() {
    blx_title "🛠️  DESARROLLO"
    blx_row "Git: $(git --version 2>/dev/null)"
    blx_row "Python: $(python3 --version 2>/dev/null)"
    blx_row "Bash: $BASH_VERSION"
    blx_bottom
}
