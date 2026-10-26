# Política de seguridad

## Alcance

BLUMIX es una utilidad local de terminal en Bash. Los comandos actuales están pensados para diagnóstico de solo lectura y descubrimiento de rutas. No son una auditoría completa ni una garantía de que un equipo esté seguro.

## Reportar un problema

Abre una incidencia privada o sigue las opciones de contacto que ofrece GitHub para el repositorio. Describe la versión, el sistema operativo, los pasos mínimos para reproducir y el impacto observado. No publiques secretos, tokens, direcciones privadas innecesarias, archivos de configuración personales ni datos de terceros.

## Prácticas del proyecto

- No almacenar contraseñas, tokens, claves privadas ni datos sensibles en Git.
- Mantener la configuración personal fuera del control de versiones.
- No ejecutar automáticamente comandos privilegiados.
- No cambiar firewall, SSH, paquetes ni servicios como efecto secundario de un diagnóstico.
- No tratar la ausencia de una herramienta como prueba de que una protección no existe.
- Revisar dependencias y cambios antes de usarlos en sistemas importantes.

## Configuración Bash

El archivo `config/blumix.conf` se lee como datos: BLUMIX acepta una lista cerrada de claves y nunca ejecuta el archivo como Bash. Solo expande el prefijo literal `$HOME` al comienzo de una ruta. Las variables de entorno explícitas prevalecen sobre las rutas del archivo. Las claves desconocidas o los valores no admitidos se ignoran. Esta protección no sustituye la revisión de la configuración ni los permisos del archivo.

## Exportación de instantáneas

`blumix report --json` produce una captura local para importar en el Atlas. El esquema omite rutas absolutas, usuario, hostname, variables de entorno y contenido de archivos, pero contiene detalles técnicos como sistema operativo, kernel, modelo de CPU, métricas de recursos y existencia de carpetas. Revísalo antes de compartirlo. El Atlas lo procesa en el navegador mediante selección explícita de archivo; no transmite el contenido a un servidor ni ejecuta código importado. La instantánea representa el momento en que se generó, no el estado actual.

## Auditoría local de señales

`blumix audit` comprueba únicamente indicadores locales limitados. No contacta la red ni eleva privilegios. La CLI sigue siendo una herramienta de diagnóstico, no una barrera de seguridad del sistema. No lee el contenido de archivos sospechosos ni imprime rutas; busca nombres de archivo de riesgo dentro del repositorio BLUMIX, no en todo el equipo ni dentro de los repositorios conectados. Un resultado limpio no demuestra ausencia de secretos ni seguridad del sistema. El JSON de auditoría no está firmado y sus resultados deben tratarse como datos informativos.

## Alcance de los diagnósticos

Los resultados son observaciones de herramientas locales y pueden estar incompletos por permisos, contenedores, distribuciones o herramientas ausentes. Para decisiones críticas, confirma los resultados con las herramientas nativas del sistema y una revisión profesional.
