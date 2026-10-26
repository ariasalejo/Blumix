# BLUMIX · Centro de Mando

**Entender → detectar → verificar → decidir.**

BLUMIX es una herramienta modular de terminal para consultar el estado de un equipo Linux y localizar herramientas del ecosistema BLUM sin fusionar sus repositorios. Su interfaz visual es una capa de operación; los proyectos integrados conservan sus propios ciclos de vida, permisos, datos y versiones.

> Estado del proyecto: versión de desarrollo 0.7.0. La CLI y los diagnósticos son locales y de solo lectura. La integración profunda con otros proyectos debe verificarse por separado.

## Atlas visual

Explora la arquitectura y la hoja de ruta en el [Atlas Visual](docs/visual-atlas/index.html). El Atlas puede importar una instantánea JSON creada por la CLI: no necesita servidor, API ni conexión continua, y nunca se presenta como telemetría en vivo.

## Capacidades de la CLI

| Comando | Función |
|---|---|
| `blumix help` | Ayuda y comandos disponibles |
| `blumix version` | Versión |
| `blumix system` | SO, kernel, tiempo activo, RAM y CPU |
| `blumix network` | Interfaces y DNS local |
| `blumix security` | Estado detectable de firewall y SSH |
| `blumix audit` / `blumix audit --json` | Revisiones locales de permisos, nombres de archivos de riesgo y estado Git; solo lectura |
| `blumix policy` / `blumix policy --json` | Catálogo de capacidades, política de denegación por defecto y límites de privilegio |
| `blumix integrations` | Descubrimiento de rutas configuradas y tolerante a mayúsculas/minúsculas para BLUMCL, BLUMSEC y BLUMELIX |
| `blumix development` | Disponibilidad de herramientas de desarrollo |
| `blumix status` | Resumen breve del equipo y las rutas |
| `blumix doctor` | Comprobaciones básicas de instalación |
| `blumix intelligence` / `blumix intel` | Diagnóstico determinista; admite `--json` con esquema `blumix.intelligence.v1` |\n| `blumix projects [--json]` | Inventario con estados `NOT_FOUND`, `DISCOVERED` y `GIT_DETECTED` |\n| `blumix services [--json]` | Procesos y unidades systemd relacionados observables, sin ejecutar acciones |
| `blumix report --json` | Crear una instantánea JSON sin rutas absolutas ni secretos para importar en el Atlas |
| `blumix blumcl` | Abrir el directorio de BLUMCL si existe |
| `blumix blumsec` | Abrir el directorio de BLUMSEC si existe |
| `blumix blumelix` | Abrir el directorio de BLUMELIX si existe |
| `blumix about` | Filosofía del proyecto |

Alias breves: `net`, `sec`, `int`, `dev`, `cl`, `elx`. Usa `blumix --help` para consultar la ayuda.

## Instalación en Ubuntu / Lubuntu / Debian

Requisitos básicos: Bash 4+, Git y utilidades estándar de Linux. Algunas métricas opcionales dependen de herramientas instaladas en el sistema.

~~~bash
git clone https://github.com/ariasalejo/Blumix.git
cd Blumix
bash tests/test_blumix.sh
./bin/blumix help
./bin/blumix audit
./bin/blumix audit --json
./bin/blumix system
./bin/blumix intelligence --json\n./bin/blumix projects --json\n./bin/blumix services --json\n./bin/blumix report --json > "$HOME/blumix-report.json"
~~~

Para ejecutar sin instalar nada en el sistema, utiliza `./bin/blumix` desde el repositorio. Si deseas el comando global, añade el directorio `bin` de tu copia local al PATH; no pegues una ruta de otra máquina sin revisarla.

Para llevar el diagnóstico a la vista visual, abre `docs/visual-atlas/index.html`, pulsa **Seleccionar informe JSON** e importa `~/blumix-report.json`. La página valida tipos y rangos antes de mostrarlo y avisa que el JSON no está firmado. El Atlas también puede instalarse como PWA desde un origen HTTPS; abrirlo como archivo local permite previsualizarlo, pero no registra el service worker. El informe incluye sistema operativo, kernel, métricas básicas y existencia de carpetas; no contiene rutas absolutas, nombre de usuario ni secretos. Revísalo antes de compartirlo: incluso la información técnica general puede revelar características de tu equipo.

## Configuración

Copia la plantilla y edita las rutas de acuerdo con tu equipo:

~~~bash
cp config/blumix.conf.example config/blumix.conf
nano config/blumix.conf
~~~

Puedes definir `BLUMCL_HOME`, `BLUMSEC_HOME` y `BLUMELIX_HOME` como rutas absolutas. También se pueden pasar como variables de entorno para una ejecución. El archivo local `config/blumix.conf` está excluido de Git.

**Seguridad de configuración:** BLUMIX lee el archivo como datos mediante una lista cerrada de claves; no lo ejecuta como Bash. Solo expande el prefijo literal `$HOME` al inicio de rutas. Las variables de entorno explícitas prevalecen sobre las rutas configuradas.

## Principios de diseño

- **Unificado, no fusionado:** cada herramienta conserva su repositorio e identidad.
- **Lectura primero:** las comprobaciones no cambian firewall, servicios ni archivos.
- **Sin secretos en Git:** credenciales, claves y configuración local no deben versionarse.
- **Offline-first:** las funciones de diagnóstico local no necesitan IA ni servicios externos.
- **IA opcional:** no es requisito de instalación ni se activa por defecto.
- **Honestidad de estado:** “directorio encontrado” no significa que una integración esté conectada ni que el servicio esté saludable.

## Centro de inteligencia local

`blumix intelligence` o `blumix intel` calcula un resumen basado en umbrales explícitos: CPU, memoria disponible (MemAvailable), disco raíz, carpetas de integración y herramientas de desarrollo detectables. Si encuentra señales de riesgo, sugiere comandos de inspección; no los ejecuta. Los resultados son heurísticos, locales y no equivalen a un análisis de causa raíz ni a una auditoría completa. No necesita IA ni conexión de red.

## Atlas y operaciones privilegiadas

El Atlas de `docs/visual-atlas/index.html` es el plano visual del ecosistema: topología, integraciones, eventos, informes y operaciones. Las instantáneas describen una captura histórica y no prueban salud en tiempo real. La web no ejecuta comandos del sistema.

`blumix policy --json` muestra el catálogo `blumix.policy.v1`. Los cambios privilegiados permanecen bloqueados y la shell arbitraria está denegada hasta implementar un agente local con autenticación, autorización por capacidad, aprobación por acción y auditoría. Consulta `docs/ATLAS-OPERATIONS-SECURITY.md` para la arquitectura y las condiciones de seguridad.

## Auditoría local

`blumix audit` revisa señales limitadas: permisos del archivo de configuración, nombres de archivos que suelen contener secretos y si existe metadato Git local. `blumix audit --json` genera el esquema `blumix.audit.v1` sin imprimir rutas ni contenidos de archivos. No usa red, no eleva privilegios y no cambia el sistema. Es una heurística: no sustituye un escáner de secretos, una revisión de dependencias ni una auditoría profesional.

## Calidad y seguridad

~~~bash
bash tests/test_blumix.sh
bash -n bin/blumix
for file in lib/*.sh; do bash -n "$file" || exit 1; done
~~~

Consulta [la arquitectura](docs/architecture/overview.md), [la instalación](docs/guides/installation.md), [la política de seguridad](SECURITY.md), [las contribuciones](CONTRIBUTING.md), el [changelog](CHANGELOG.md) y el [roadmap](ROADMAP.md).

## Licencia

MIT, según el archivo LICENSE del repositorio.


## Estados de evidencia

- `blumix projects` distingue recurso ausente (`NOT_FOUND`), carpeta encontrada (`DISCOVERED`) y metadatos Git detectados (`GIT_DETECTED`). No ejecuta pruebas funcionales ni declara una aplicación saludable.
- `blumix services` observa nombres de procesos y unidades systemd que identifiquen explícitamente BLUMIX, BLUMCL, BLUMSEC o BLUMELIX. La ausencia de coincidencias queda como desconocida; no demuestra que un servicio esté detenido.
- `blumix intelligence --json`, `blumix projects --json` y `blumix services --json` emiten JSON estructurado en stdout; los argumentos inválidos devuelven código 2.
- El Atlas/PWA existente es una interfaz estática offline-first que importa informes elegidos por el usuario. No es un servidor de diagnóstico en vivo ni presenta informes antiguos como telemetría actual. El service worker solo cachea la interfaz estática.
