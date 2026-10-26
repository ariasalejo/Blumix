#!/usr/bin/env bash
blumix_security() {
    blx_title "SEGURIDAD — ESTADO OBSERVABLE"
    blx_row "Usuario: ${USER:-$(id -un 2>/dev/null || printf N/D)}"

    local detected=0
    if blumix_command_exists ufw; then
        detected=1
        if ufw status 2>/dev/null | grep -qi '^Status: active'; then
            blx_row "Firewall UFW: activo"
        elif ufw status 2>/dev/null | grep -qi '^Status: inactive'; then
            blx_warn "Firewall UFW: instalado pero inactivo"
        else
            blx_warn "Firewall UFW: no se pudo determinar el estado"
        fi
    fi
    if blumix_command_exists firewall-cmd; then
        detected=1
        if firewall-cmd --state >/dev/null 2>&1; then
            blx_row "Firewall firewalld: activo"
        else
            blx_warn "Firewall firewalld: instalado pero no responde como activo"
        fi
    fi
    if (( detected == 0 )); then
        blx_warn "No se detectó UFW ni firewalld; esto no demuestra que no haya reglas de firewall."
    fi

    if blumix_command_exists systemctl; then
        if systemctl is-active --quiet ssh.service 2>/dev/null || systemctl is-active --quiet sshd.service 2>/dev/null; then
            blx_warn "Servicio SSH: activo (revisa si necesitas acceso remoto)"
        elif systemctl list-unit-files ssh.service sshd.service --no-legend 2>/dev/null | grep -Eq 'ssh(d)?\.service'; then
            blx_row "Servicio SSH: instalado, no activo"
        else
            blx_row "Servicio SSH: no detectado por systemd"
        fi
    else
        blx_warn "systemctl no disponible; no se puede consultar el estado del servicio SSH."
    fi
    blx_warn "Diagnóstico informativo: no modifica reglas ni servicios."
    blx_bottom
}
