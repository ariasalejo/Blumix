cat > docs/guides/configuration.md <<'EOF'
⚙️ Configuración
Blumix usa un archivo de configuración opcional en config/blumix.conf.
Crear configuración

# Copiar plantilla
cp config/blumix.conf.example config/blumix.conf

# Editar
nano config/blumix.conf

Variables disponibles
Rutas de integración

# Rutas de los proyectos integrados
BLUMCL_HOME="$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumcl"
BLUMSEC_HOME="$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumsec"
BLUMELIX_HOME="$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumelix"

Apariencia

# Tema: dark (oscuro) o light (claro)
BLUMIX_THEME="dark"

# Idioma: es (español) o en (inglés)
BLUMIX_LANG="es"

Funcionalidades

# Activar IA local (0 = desactivado, 1 = activado)
# Por defecto desactivado para proteger máquinas con pocos recursos
BLUMIX_AI_ENABLED=0

Variables de entorno (override)
Las variables de entorno tienen prioridad sobre el archivo de configuración:


# Sobrescribir ruta de Blumcl
export BLUMCL_HOME="/otra/ruta/Blumcl"

# Ejecutar Blumix
blumix integrations

Configuración por máquina
Puedes tener configuraciones diferentes en cada máquina:
PC de escritorio (Fedora):

BLUMIX_AI_ENABLED=0
BLUMIX_THEME="dark"

Servidor (Ubuntu):


BLUMIX_AI_ENABLED=0
BLUMIX_THEME="light"


Configuración avanzada
Personalizar colores
Editar lib/ui.sh:


# Cambiar color de títulos
BLX_CYAN=$'\033[1;34m'  # Azul en lugar de cyan

# Cambiar color de información
BLX_GREEN=$'\033[1;36m'  # Cyan en lugar de verde

Personalizar comandos
Editar bin/blumix:

# Añadir nuevo comando
case "${1:-help}" in
    # ... comandos existentes ...
    mi-comando) mi_funcion ;;
esac

Personalizar módulos
Cada módulo en lib/ puede editarse independientemente

# Ejemplo: añadir información personalizada a system.sh
nano lib/system.sh

Seguridad
El archivo config/blumix.conf está en .gitignore para proteger secretos:


# .gitignore
config/blumix.conf
config/*.local

Solo config/blumix.conf.example se sube a Git.
EOF
