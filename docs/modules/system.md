cat > docs/modules/system.md <<'EOF'
🖥️ Módulo: system
El módulo system muestra información del sistema operativo y hardware.
Uso

blumix system

Información mostrada
Campo
	
Descripción
	
Comando usado
OS
	
Nombre y versión del sistema
	
/etc/os-release
Host
	
Nombre del host
	
hostname
Kernel
	
Versión del kernel
	
uname -r
Uptime
	
Tiempo encendido
	
uptime -p
RAM
	
Memoria usada/total
	
free -h
Swap
	
Swap usado/total
	
free -h
Disco
	
Espacio usado/total en /
	
df -h /
CPU
	
Modelo de procesador
	
Información mostrada
Campo
	
Descripción
	
Comando usado
OS
	
Nombre y versión del sistema
	
/etc/os-release
Host
	
Nombre del host
	
hostname
Kernel
	
Versión del kernel
	
uname -r
Uptime
	
Tiempo encendido
	
uptime -p
RAM
	
Memoria usada/total
	
free -h
Swap
	
Swap usado/total
	
free -h
Disco
	
Espacio usado/total en /
	
df -h /
CPU
	
Modelo de procesador
	
lscpu
Ejemplo de salida

╔══════════════════════════════════════════════════════════════════════════════╗
║ 🖥️  SISTEMA
╚══════════════════════════════════════════════════════════════════════════════╝
  OS     : Fedora Linux 44 (Xfce)
  Host   : fedora
  Kernel : 7.1.5-201.fc44.x86_64
  Uptime : up 6 hours, 21 minutes
  RAM    : 3.3Gi / 3.7Gi
  Swap   : 0B / 2.0Gi
  Disco  : 45G / 100G (45%)
  CPU    : AMD A9-9425 RADEON R5, 5 COMPUTE CORES 2C+3G

Implementación
Archivo: lib/system.sh

blumix_system() {
    clear 2>/dev/null
    blx_title "🖥️  SISTEMA"
    blx_row "OS     : $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || echo N/D)"
    blx_row "Host   : $(hostname 2>/dev/null || echo N/D)"
    blx_row "Kernel : $(uname -r 2>/dev/null || echo N/D)"
    blx_row "Uptime : $(uptime -p 2>/dev/null || echo N/D)"
    blx_row "RAM    : $(free -h 2>/dev/null | awk '/^Mem:/ {printf "%s / %s", $3, $2}')"
    blx_row "Swap   : $(free -h 2>/dev/null | awk '/^Swap:/ {printf "%s / %s", $3, $2}')"
    blx_row "Disco  : $(df -h / 2>/dev/null | awk 'NR==2 {printf "%s / %s (%s)", $3, $2, $5}')"
    blx_row "CPU    : $(lscpu 2>/dev/null | grep 'Model name' | cut -d: -f2 | xargs || echo N/D)"
    blx_bottom
}

Compatibilidad

    ✅ Fedora 40+
    ✅ Ubuntu 22.04+
    ✅ Debian 12+
    ✅ Termux (Android)
    ⚠️ macOS (algunos comandos pueden variar)

Personalización
Para añadir más información, editar lib/system.sh:


blx_row "GPU    : $(lspci | grep VGA | cut -d: -f3)"
blx_row "Temp   : $(sensors | grep 'Package id 0' | awk '{print $4}')"

EOF




