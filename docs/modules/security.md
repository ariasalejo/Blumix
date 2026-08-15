cat > docs/modules/security.md <<'EOF'
🔐 Módulo: security
El módulo security muestra el estado de los servicios de seguridad del sistema.
Uso

blumix security

Información mostrada
Campo
	
Descripción
	
Comando usado
Usuario
	
Usuario actual y UID
	
id -u
Firewall
	
Estado del firewall
	
firewall-cmd --state
SSH
	
Estado del servicio SSH
	
systemctl is-active sshd
SELinux
	
Estado de SELinux (Fedora)
	
getenforce
Ejemplo de salida


╔══════════════════════════════════════════════════════════════════════════════╗
║ 🔐 SEGURIDAD
╚══════════════════════════════════════════════════════════════════════════════╝
  Usuario : usuario (UID 1000)
  🔥 Firewall : activo
  🔑 SSH      : activo
  🛡️  SELinux  : Enforcing

Estados posibles
Firewall

    🔥 Firewall : activo — firewall-cmd está corriendo
    🔥 Firewall : inactivo — firewall-cmd instalado pero no activo
    🔥 Firewall : firewall-cmd no disponible — no instalado

SSH

    🔑 SSH : activo — sshd está corriendo
    🔑 SSH : inactivo — sshd no está corriendo

SELinux (solo Fedora/RHEL)

    Enforcing — SELinux activo y aplicando políticas
    Permissive — SELinux activo pero solo registrando
    Disabled — SELinux desactivado

Implementación
Archivo: lib/security.sh

blumix_security() {
    clear 2>/dev/null
    blx_title "🔐 SEGURIDAD"
    blx_row "Usuario : ${USER:-N/D} (UID $(id -u 2>/dev/null))"
    if command -v firewall-cmd >/dev/null 2>&1; then
        firewall-cmd --state >/dev/null 2>&1 \
            && blx_row "🔥 Firewall : activo" \
            || blx_warn "🔥 Firewall : inactivo"
    else
        blx_warn "🔥 Firewall : firewall-cmd no disponible"
    fi
    systemctl is-active --quiet sshd 2>/dev/null \
        && blx_row "🔑 SSH      : activo" \
        || blx_warn "🔑 SSH      : inactivo"
    command -v getenforce >/dev/null 2>&1 && blx_row "🛡️  SELinux  : $(getenforce 2>/dev/null)"
    blx_bottom
}

Compatibilidad

    ✅ Fedora (firewall-cmd, SELinux)
    ✅ Ubuntu/Debian (ufw en lugar de firewall-cmd)
    ⚠️ macOS (pf en lugar de firewall-cmd)

Acciones recomendadas
Si el firewall está inactivo:

# Fedora
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Ubuntu/Debian
sudo ufw enable

Si SSH está inactivo:

sudo systemctl start sshd
sudo systemctl enable sshd

Si SELinux está en Permissive:

sudo setenforce 1

EOF
