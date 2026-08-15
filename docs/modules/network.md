# 🌐 Módulo: network

El módulo `network` muestra información de las interfaces de red y conectividad.

## Uso

```bash
blumix network

Información mostrada
Campo
	
Descripción
	
Comando usado
Interfaces
	
Lista de interfaces con IPs
	
ip -brief address
Gateway
	
Puerta de enlace predeterminada
	
ip route
DNS
	
Servidor DNS primario
	
/etc/resolv.conf
IP externa
	
IP pública (requiere internet)
	
curl ifconfig.me
Ejemplo de salida


╔══════════════════════════════════╗ ║ 🌐 RED ╚══════════════════════════════════╝ Interfaces: lo UNKNOWN 127.0.0.1/8 wlan0 UP IP-EJEMPLO/24 Gateway : 192.168.1.1 DNS : 192.168.1.1 IP ext : 200.24.135.67


Implementación
Archivo: lib/network.sh

blumix_network() {
    clear 2>/dev/null
    blx_title "🌐 RED"
    blx_row "Interfaces:"
    ip -brief address 2>/dev/null | while IFS= read -r l; do printf '    %s\n' "$l"; done
    blx_row "Gateway : $(ip route 2>/dev/null | awk '/default/ {print $3; exit}')"
    blx_row "DNS     : $(grep nameserver /etc/resolv.conf 2>/dev/null | head -1 | awk '{print $2}')"
    blx_row "IP ext  : $(curl -s -m 3 ifconfig.me 2>/dev/null || echo 'sin internet')"
    blx_bottom
}

Sin internet
Si no hay conexión:


  IP ext  : sin internet


