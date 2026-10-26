# Puertas de calidad

Este documento define evidencia mínima para evitar anunciar como terminadas capacidades que solo están diseñadas.

## Para cada cambio

- La sintaxis Bash debe ser válida.
- Las pruebas automatizadas deben pasar.
- Los comandos nuevos deben tener ayuda y un comportamiento de error definido.
- La documentación debe describir lo que el código hace hoy.
- Las rutas y nombres de usuario específicos de una máquina no deben ser requisitos.
- Los diagnósticos deben distinguir entre activo, inactivo, no detectado y no verificable.

## Antes de una release

1. Ejecutar las pruebas en un entorno limpio.
2. Revisar ShellCheck y corregir hallazgos relevantes.
3. Confirmar que no se agregaron secretos ni archivos locales.
4. Verificar que las rutas de integración son configurables.
5. Revisar el diff completo contra la rama base.
6. Anotar limitaciones conocidas y pasos de reversión.

## Lo que no cuenta como evidencia

- Que un archivo exista.
- Que la documentación describa una función.
- Que el Atlas visual muestre un componente.
- Que una prueba solo compruebe que el comando termina sin error.

La evidencia debe vincularse al comportamiento real y a una prueba reproducible.
