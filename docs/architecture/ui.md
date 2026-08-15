cat > docs/architecture/ui.md <<'EOF'
🎨 UI Responsiva
Blumix usa una UI basada en caracteres ANSI que se adapta automáticamente al ancho de la terminal.
Detección de columnas

blx_cols() {
    local c
    c="$(tput cols 2>/dev/null || echo 80)"
    [[ "$c" =~ ^[0-9]+$ ]] || c=80
    echo "$c"
}

Ancho adaptativo

    Mínimo: 40 columnas
    Máximo: 76 columnas
    Por defecto: ancho de terminal - 4

Colores ANSI

Color
	
Código
	
Uso
Cyan
	
\033[1;36m
	
Títulos, bordes
Green
	
\033[1;32m
	
Información normal
Yellow
	
\033[1;33m
	
Advertencias
Red
	
\033[1;31m
	
Errores
Bold
	
\033[1m
	
Texto destacado
Reset
	
\033[0m
	
Volver a normal

Cajas responsivas

blx_title() { local w=$(blx_width) printf '%b╔' "$BLX_CYAN" printf '═%.0s' $(seq 1 $w) printf '╗\n' printf '║%b %s%b\n' "$BLX_BOLD" "$1" "$BLX_RESET" printf '%b╚' "$BLX_CYAN" printf '═%.0s' $(seq 1 $w) printf '╝%b\n' "$BLX_RESET" }

Ejemplo de salida
Terminal de 80 columnas:

╔══════════════════════════════════════════════════════════════════════════════╗
║ 🖥️  SISTEMA
╚══════════════════════════════════════════════════════════════════════════════╝
  OS     : Fedora Linux 44 (Xfce)
  Host   : fedora
  Kernel : 7.1.5-201.fc44.x86_64

Compatibilidad

    ✅ Bash 4+
    ✅ Terminales con soporte ANSI
    ✅ Termux (Android)
    ✅ GNOME Terminal, Konsole, xterm
    ❌ Terminales sin colores (fallback a texto plano)
    EOF
