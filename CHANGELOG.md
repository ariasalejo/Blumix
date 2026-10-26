# Changelog

Cambios notables por versión.

## [Unreleased]

- Próximas mejoras sujetas a implementación y pruebas.

## [0.4.0] - En desarrollo

### Corregido
- README y documentación de arquitectura que contenían comandos de shell como contenido de archivo.
- Rutas predeterminadas de integración para permitir detección de directorios conocidos y configuración explícita.
- Módulo de seguridad que asumía herramientas de Fedora al consultar firewall y SSH.
- Módulo de integraciones que omitía BLUMELIX.
- CLI que no ofrecía ayuda clara ni manejaba los comandos desconocidos.

### Añadido
- Comando `doctor` de comprobación local.
- Alias cortos para algunos comandos.
- Pruebas para ayuda, versión, sintaxis, integraciones y errores de uso.
- Documentación de seguridad y contribución.
- Atlas visual interactivo en `docs/visual-atlas/`.

### Límites
- No se declara conexión API ni salud de servicios a partir de la mera existencia de una carpeta.
- No se han añadido acciones destructivas, cambios automáticos de firewall ni activación de IA.

## [0.1.0]

- Estructura inicial del proyecto y definición conceptual.
