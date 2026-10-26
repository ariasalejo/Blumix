# Changelog

Cambios notables por versión.

## [Unreleased]

- Añade `blumix projects [--json]` y `blumix services [--json]` con estados de evidencia y límites explícitos; la ausencia de coincidencias no se interpreta como ausencia de servicios.
- Añade `blumix intelligence --json` con salida estructurada, fuentes y estados desconocidos.
- Amplía pruebas automatizadas para esquemas JSON, estados desconocidos y argumentos inválidos.

- Nuevo `blumix intelligence` / `blumix intel`: reglas locales para detectar carga elevada, memoria disponible reducida, disco bajo y brechas de integración; recomienda comprobaciones de solo lectura sin ejecutarlas.
- El centro de mando muestra el diagnóstico accionable y la detección de herramientas de desarrollo.
- Pruebas automatizadas para el nuevo comando, alias y declaración de límites.

- Agente local autenticado, comprobaciones reales de salud por integración y aplicación Android nativa; aún no implementados.

## [0.7.0-atlas-redesign] - En desarrollo

### Atlas / control del ecosistema
- Rediseño completo del Atlas: topología SVG interactiva, navegación por vistas, registro de eventos, integraciones, métricas importadas y consola de comandos manuales.
- Nuevo `blumix policy` / `blumix policy --json` con catálogo de capacidades y política de denegación por defecto.
- Operaciones privilegiadas explícitamente bloqueadas; `run_shell` denegada. Ninguna operación se ejecuta desde la web.
- Documento de arquitectura para agente local, autorización por capacidad, aprobación por operación, privilegio mínimo y auditoría.
- Pruebas para el esquema de política, capacidades bloqueadas y nuevo diseño del Atlas.

## [0.7.0] - En desarrollo

### Seguridad y diagnóstico
- Nuevo `blumix audit` y `blumix audit --json`: comprobaciones locales de permisos, nombres de archivos de riesgo y estado Git, sin imprimir rutas ni contenidos.
- La configuración se interpreta como datos con lista cerrada de claves; elimina la ejecución accidental de código Bash desde `config/blumix.conf`.
- El Atlas valida tipos, rangos y secciones de los JSON importados y advierte que las instantáneas no están firmadas ni autenticadas.

### Web / PWA
- Manifiesto, icono SVG y service worker con caché de la interfaz estática para instalación PWA desde HTTPS.
- La caché no incluye informes locales ni datos de API; el Atlas mantiene su modo local-first sin dependencias remotas.

## [0.6.0] - En desarrollo

### Añadido
- Exportación `blumix report --json` con esquema versionado y sin rutas absolutas, usuario, hostname ni secretos.
- Atlas local-first capaz de importar una instantánea JSON seleccionada por el usuario, sin servidor, API ni conexión de red.
- Métricas de CPU, RAM, disco y tiempo activo junto con el estado de existencia de carpetas detectado por la CLI.

### Seguridad y calidad
- Informe limitado a observaciones locales; no declara salud de servicios ni conexión en vivo.
- `NO_COLOR` y salida redirigida sin secuencias ANSI.
- Pruebas de regresión para validez JSON, metadatos de privacidad, ayuda y versión.

## [0.5.0] - En desarrollo

### Añadido
- Dashboard de terminal con identidad visual, mapa de estaciones, HUD de recursos, información del sistema e integraciones en una sola vista.
- Acceso rápido a comandos de diagnóstico desde el centro de mando.
- Modo sin animaciones cuando la salida no es una terminal interactiva, para facilitar logs, pruebas y automatización.

### Seguridad
- El panel reitera que detectar una carpeta no demuestra que un servicio esté saludable.
- No se ejecutan cambios de configuración ni acciones privilegiadas desde el dashboard.

## [0.4.1] - En desarrollo

### Corregido
- Descubrimiento de carpetas de proyectos sin asumir una capitalización exacta del nombre en Linux.
- Etiqueta de CPU con alternativa a `/proc/cpuinfo` cuando `lscpu` no devuelve el modelo.
- HUD: no dibuja métricas desconocidas como cero y no interpreta una batería ausente como 0%. 

### Pruebas
- Añadida regresión para rutas con capitalización mixta en un HOME temporal; no toca los proyectos del usuario.

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
