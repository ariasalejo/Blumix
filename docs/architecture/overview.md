cat > docs/architecture/overview.md <<'EOF'
🏗️ Arquitectura de Blumix
Ecosistema BLUM
Blumix es el orquestador del ecosistema BLUM. No reemplaza ni fusiona los proyectos, los conecta mediante variables de entorno y rutas.

          🌌 BLUM ECOSYSTEM
                 │
            ┌────▼────┐
            │ BLUMIX  │
            │ORQUESTADOR│
            └────┬────┘
                 │
    ┌────────────┼────────────┐
    ▼            ▼            ▼
 BLUMCL       BLUMSEC     BLUMELIX
análisis     seguridad     servicios
Android      bóveda        web app
Termux       cifrado       Flask


Blumix/
├── bin/
│   └── blumix              # Ejecutable principal (dispatcher)
├── lib/                    # Módulos del sistema
│   ├── core.sh             # Constantes, utilidades, carga de config
│   ├── ui.sh               # UI responsiva con cajas ANSI
│   ├── system.sh           # Diagnóstico: OS, CPU, RAM, disco
│   ├── network.sh          # Red: interfaces, DNS, IP externa
│   ├── security.sh         # Firewall, SSH, SELinux
│   ├── development.sh      # Herramientas: Git, Python, Bash
│   └── integrations.sh     # Conexión con Blumcl/Blumsec/Blumelix
├── config/
│   └── blumix.conf.example # Plantilla de configuración
├── docs/                   # Documentación completa
├── tests/
│   └── test_blumix.sh      # Tests automatizados
└── tools/
    └── update_readme.py    # Sincroniza ROADMAP → README

blumix <comando>
    ↓
bin/blumix (dispatcher)
    ↓
lib/core.sh (carga constantes)
    ↓
lib/ui.sh (inicializa colores)
    ↓
lib/<modulo>.sh (ejecuta función específica)
    ↓
Salida en terminal con UI responsiva

Filosofía de diseño

    Unificado, no fusionado — cada proyecto conserva su identidad, repo y versiones
    Sin IA por defecto — protege máquinas con pocos recursos (AMD A9, 4GB RAM)
    Zero-trust — nunca confíes, siempre verifica
    Responsive — la UI se adapta al ancho real de la terminal (40-76 columnas)
    Offline-first — todo funciona sin internet
    Sin secretos en git — .gitignore robusto protege archivos sensibles

Variables de entorno
Variable
	
Descripción
	
Por defecto
BLUMIX_HOME
	
Ruta de Blumix
	
$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumix
BLUMCL_HOME
	
Ruta de Blumcl
	
$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumcl
BLUMSEC_HOME
	
Ruta de Blumsec
	
$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumsec
BLUMELIX_HOME
	
Ruta de Blumelix
	
$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumelix
BLUMIX_THEME
	
Tema (dark/light)
	
dark
BLUMIX_LANG
	
Idioma (es/en)
	
es
BLUMIX_AI_ENABLED
	
Activar IA (0/1)
	
0
EOF
	
	
