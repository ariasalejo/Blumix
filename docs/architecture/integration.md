cat > docs/architecture/integration.md <<'EOF'
🧩 Integraciones
Blumix se conecta con otros proyectos mediante variables de entorno y rutas, sin fusionar repositorios.
Arquitectura de integración

BLUMIX (orquestador)
    │
    ├── BLUMCL_HOME → ~/Ciberseguridad/.../Blumcl
    ├── BLUMSEC_HOME → ~/Ciberseguridad/.../Blumsec
    └── BLUMELIX_HOME → ~/Ciberseguridad/.../Blumelix

Cada proyecto conserva:

    ✅ Su propio repositorio Git
    ✅ Su propio README
    ✅ Sus propios tests
    ✅ Su propio roadmap
    ✅ Sus propias versiones

Variables de entorno

export BLUMCL_HOME="${BLUMCL_HOME:-$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumcl}"
export BLUMSEC_HOME="${BLUMSEC_HOME:-$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumsec}"
export BLUMELIX_HOME="${BLUMELIX_HOME:-$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumelix}"

Comandos de integración
Ver estado

blumix integrations

Salida:

🧩 INTEGRACIONES
  ✅ BLUMCL   : /home/usuario/.../Blumcl
  ✅ BLUMSEC  : /home/usuario/.../Blumsec
  ✅ BLUMELIX : /home/usuario/.../Blumelix

Navegar a proyectos

blumix blumcl      # cd a Blumcl + abre bash
blumix blumsec     # cd a Blumsec + abre bash
blumix blumelix    # cd a Blumelix + abre bash

Ejemplo de uso

# Ver estado de todos los proyectos
blumix integrations

# Ir a Blumsec y ejecutar su servidor
blumix blumsec
./blumelix-server.sh

# Volver a Blumix
exit

Beneficios

    Independencia — cada proyecto evoluciona a su ritmo
    Claridad — un solo lugar para ver el estado de todo
    Navegación rápida — saltar entre proyectos con un comando
    Sin conflictos — cada repo tiene su propio .gitignore
    EOF
