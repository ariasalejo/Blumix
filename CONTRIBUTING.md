# Guía de contribución

Gracias por mejorar BLUMIX.

## Antes de cambiar código

1. Lee la arquitectura y el roadmap.
2. Comprueba el comportamiento actual con las pruebas.
3. Trabaja en una rama separada.
4. Mantén BLUMIX y los proyectos integrados como repositorios independientes.
5. No incluyas credenciales, datos personales, archivos locales de configuración ni rutas que solo existan en tu equipo.

## Convenciones

- Bash compatible con Bash 4+.
- Usa nombres descriptivos y cita variables de rutas: `"$path"`.
- Evita `eval`, descargas ejecutadas directamente y elevación automática de privilegios.
- Los diagnósticos deben ser de solo lectura.
- Si una capacidad depende de una utilidad opcional, muestra un estado honesto en vez de fallar silenciosamente.
- No marques una integración como saludable solo porque existe su directorio.
- Actualiza documentación y pruebas junto con cada cambio de comportamiento.

## Validación local

~~~bash
bash tests/test_blumix.sh
bash -n bin/blumix
for file in lib/*.sh; do bash -n "$file" || exit 1; done
~~~

Si ShellCheck está instalado, ejecuta `shellcheck bin/blumix lib/*.sh tests/test_blumix.sh`.

## Pull requests

Explica el problema, la solución, las pruebas ejecutadas y las limitaciones que siguen abiertas. Los cambios que afecten a seguridad o a la configuración deben incluir una nota explícita de riesgos y reversión.
