cat > docs/modules/integrations.md <<'EOF'
🧩 Módulo: integrations
El módulo integrations muestra el estado de los proyectos conectados a Blumix.
Uso


blumix integrations

1

Proyectos integrados
Proyecto
	
Descripción
	
Variable
Blumcl
	
Auditoría de almacenamiento Termux/Android
	
BLUMCL_HOME
Blumsec
	
Notario digital (bóveda cifrada)
	
BLUMSEC_HOME
Blumelix
	
App web Flask con 44 funciones
	
BLUMELIX_HOME
Ejemplo de salida

╔══════════════════════════════════════════════════════════════════════════════╗
║ 🧩 INTEGRACIONES
╚══════════════════════════════════════════════════════════════════════════════╝
  ✅ BLUMCL   : /home/usuario/proyectos/03_Proyectos_y_Trabajos/Blumcl
  ✅ BLUMSEC  : /home/usuario/proyectos/03_Proyectos_y_Trabajos/Blumsec
  ✅ BLUMELIX : /home/usuario/proyectos/03_Proyectos_y_Trabajos/Blumelix

Estados

    ✅ — Proyecto encontrado en la ruta configurada
    ❌ — Proyecto no encontrado

Navegar a proyectos

# Ir a Blumcl
blumix blumcl

# Ir a Blumsec
blumix blumsec

# Ir a Blumelix
blumix blumelix

Cada comando hace cd al directorio del proyecto y abre una nueva sesión de bash.
Implementación
Archivo: lib/integrations.sh

blumix_integrations() {
    clear 2>/dev/null
    blx_title "🧩 INTEGRACIONES"
    blumix_dir_exists "$BLUMCL_HOME"   && blx_row "✅ BLUMCL   : $BLUMCL_HOME"   || blx_warn "❌ BLUMCL   : no encontrado"
    blumix_dir_exists "$BLUMSEC_HOME"  && blx_row "✅ BLUMSEC  : $BLUMSEC_HOME"  || blx_warn "❌ BLUMSEC  : no encontrado"
    blumix_dir_exists "$BLUMELIX_HOME" && blx_row "✅ BLUMELIX : $BLUMELIX_HOME" || blx_warn "❌ BLUMELIX : no encontrado"
    blx_bottom
}

blumix_go_blumcl()   { blumix_dir_exists "$BLUMCL_HOME"   && cd "$BLUMCL_HOME"   && exec bash || blx_err "BLUMCL no disponible"; }
blumix_go_blumsec()  { blumix_dir_exists "$BLUMSEC_HOME"  && cd "$BLUMSEC_HOME"  && exec bash || blx_err "BLUMSEC no disponible"; }
blumix_go_blumelix() { blumix_dir_exists "$BLUMELIX_HOME" && cd "$BLUMELIX_HOME" && exec bash || blx_err "BLUMELIX no disponible"; }

Personalización
Añadir nuevo proyecto
Editar lib/integrations.sh:

# Añadir variable en lib/core.sh
export BLUMNEW_HOME="${BLUMNEW_HOME:-$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumnew}"

# Añadir en blumix_integrations()
blumix_dir_exists "$BLUMNEW_HOME" && blx_row "✅ BLUMNEW  : $BLUMNEW_HOME" || blx_warn "❌ BLUMNEW  : no encontrado"

# Añadir función de navegación
blumix_go_blumnew() { blumix_dir_exists "$BLUMNEW_HOME" && cd "$BLUMNEW_HOME" && exec bash || blx_err "BLUMNEW no disponible"; }

Añadir comando en bin/blumix


case "${1:-help}" in
    # ... comandos existentes ...
    blumnew) blumix_go_blumnew ;;
esac
EOF
