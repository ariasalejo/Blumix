cat > docs/guides/installation.md <<'EOF'
📦 Instalación
Requisitos

    Sistema: Fedora/Debian/Ubuntu/Termux
    Shell: Bash 4+
    Herramientas: Git, curl, ip, free, df

Instalación rápida

# 1. Clonar repositorio
git clone https://github.com/ariasalejo/Blumix.git
cd Blumix

# 2. Dar permisos de ejecución
chmod +x bin/blumix lib/*.sh

# 3. Añadir al PATH
echo 'export PATH="$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumix/bin:$PATH"' >> ~/.bashrc
echo 'alias blx="blumix"' >> ~/.bashrc

# 4. Recargar configuración
source ~/.bashrc

# 5. Verificar instalación
blumix version

Instalación manual (sin PATH)
Si no quieres modificar ~/.bashrc:

# Usar ruta completa
~/Ciberseguridad/03_Proyectos_y_Trabajos/Blumix/bin/blumix system

# O crear symlink
sudo ln -s ~/Ciberseguridad/03_Proyectos_y_Trabajos/Blumix/bin/blumix /usr/local/bin/blumix

Variables disponibles:

    BLUMCL_HOME — ruta de Blumcl
    BLUMSEC_HOME — ruta de Blumsec
    BLUMIX_THEME — tema (dark/light)
    BLUMIX_AI_ENABLED — activar IA (0/1)

Verificación

# Ver versión
blumix version

# Ver diagnóstico del sistema
blumix system

# Ver estado de integraciones
blumix integrations

# Ejecutar tests
./tests/test_blumix.sh

Desinstalación

# Eliminar del PATH nano ~/.bashrc # Borrar líneas de Blumix # Eliminar archivos rm -rf ~/Ciberseguridad/03_Proyectos_y_Trabajos/Blumix # Recargar source ~/.bashrc

Solución de problemas
"blumix: command not found"

# Verificar PATH echo $PATH | grep Blumix # Si no aparece, añadir manualmente export PATH="$HOME/Ciberseguridad/03_Proyectos_y_Trabajos/Blumix/bin:$PATH"

"Permission denied"

# Dar permisos
chmod +x ~/Ciberseguridad/03_Proyectos_y_Trabajos/Blumix/bin/blumix
chmod +x ~/Ciberseguridad/03_Proyectos_y_Trabajos/Blumix/lib/*.sh

Tests fallan

# Verificar sintaxis
bash -n bin/blumix
bash -n lib/core.sh

# Verificar ejecución
./bin/blumix version

EOF

