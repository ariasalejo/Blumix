#!/usr/bin/env bash
blumix_security() {
    blx_title "🔐 SEGURIDAD"
    blx_row "Usuario: ${USER:-N/D}"
    firewall-cmd --state >/dev/null 2>&1 && blx_row "🔥 Firewall: activo" || blx_row "🔥 Firewall: inactivo"
    systemctl is-active --quiet sshd 2>/dev/null && blx_row "🔑 SSH: activo" || blx_row "🔑 SSH: inactivo"
    blx_bottom
}
