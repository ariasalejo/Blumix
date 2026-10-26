# Instalación y uso

## Requisitos

- Bash 4 o posterior.
- Git para clonar el repositorio.
- Utilidades habituales de Linux: awk, sed, free, df, ip y systemctl (algunas son opcionales según el módulo).

## Obtener y probar

~~~bash
git clone https://github.com/ariasalejo/Blumix.git
cd Blumix
bash tests/test_blumix.sh
./bin/blumix help
./bin/blumix system
./bin/blumix integrations
~~~

No es obligatorio instalar paquetes adicionales ni usar `sudo` para ejecutar los diagnósticos básicos.

## Ejecutar desde cualquier ubicación

La opción más simple es usar la ruta al script:

~~~bash
/path/a/Blumix/bin/blumix help
~~~

Para añadir la copia local al PATH, sustituye la ruta del ejemplo por la ubicación real:

~~~bash
printf '\nexport PATH="%s/bin:$PATH"\n' "$HOME/04_DEVELOPMENT/08_Proyectos/Blum/Blumix" >> "$HOME/.bashrc"
~~~

Después abre una nueva terminal o ejecuta `source ~/.bashrc`. Evita añadir repetidamente la misma línea. No copies rutas históricas sin verificar que existan en tu equipo.

## Configurar rutas de proyectos

~~~bash
cp config/blumix.conf.example config/blumix.conf
nano config/blumix.conf
~~~

Descomenta y ajusta las rutas que realmente existen. También puedes sobrescribir una ruta para una sola ejecución:

~~~bash
BLUMSEC_HOME="$HOME/ruta/real/Blumsec" ./bin/blumix integrations
~~~

El archivo de configuración se interpreta como código Bash: solo carga una configuración que tú hayas revisado. El archivo local está excluido de Git.

## Comandos útiles

~~~bash
./bin/blumix help
./bin/blumix version
./bin/blumix doctor
./bin/blumix status
./bin/blumix network
./bin/blumix security
~~~

## Solución de problemas

- **Permission denied:** ejecuta `bash bin/blumix help` para comprobar el archivo sin depender del bit ejecutable; revisa permisos antes de cambiarlos.
- **Directorio no encontrado:** ajusta la variable correspondiente en la configuración local o en el entorno.
- **Firewall desconocido:** que UFW o firewalld no aparezcan no demuestra que el sistema carezca de reglas de firewall.
- **Pruebas:** ejecuta `bash tests/test_blumix.sh` y revisa el primer error informado.

## Desinstalación

Si solo clonaste el repositorio, la desinstalación consiste en retirar la carpeta clonada y quitar manualmente del PATH cualquier línea que añadiste. Comprueba la ruta antes de borrar nada; BLUMIX no proporciona un desinstalador automático.
