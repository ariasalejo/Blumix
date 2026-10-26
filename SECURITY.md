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

El archivo `config/blumix.conf` se carga como código Bash. Solo debe contener valores que el usuario haya revisado. Nunca cargues archivos de configuración descargados de fuentes no confiables.

## Alcance de los diagnósticos

Los resultados son observaciones de herramientas locales y pueden estar incompletos por permisos, contenedores, distribuciones o herramientas ausentes. Para decisiones críticas, confirma los resultados con las herramientas nativas del sistema y una revisión profesional.
