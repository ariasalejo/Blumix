# BLUMIX · Centro de Mando

**Entender → detectar → verificar → decidir.**

BLUMIX es una herramienta modular de terminal para consultar el estado de un equipo Linux y localizar herramientas del ecosistema BLUM sin fusionar sus repositorios. Su interfaz visual es una capa de operación; los proyectos integrados conservan sus propios ciclos de vida, permisos, datos y versiones.

> Estado del proyecto: versión de desarrollo 0.5.0. La CLI y los diagnósticos son locales y de solo lectura. La integración profunda con otros proyectos debe verificarse por separado.

## Atlas visual

Explora la arquitectura, los componentes y la hoja de ruta en el [Atlas Visual Interactivo](docs/visual-atlas/index.html). La guía explica el diseño; no es un panel conectado en tiempo real.

## Capacidades de la CLI

| Comando | Función |
|---|---|
| `blumix help` | Ayuda y comandos disponibles |
| `blumix version` | Versión |
| `blumix system` | SO, kernel, tiempo activo, RAM y CPU |
| `blumix network` | Interfaces y DNS local |
| `blumix security` | Estado detectable de firewall y SSH |
| `blumix integrations` | Descubrimiento de rutas configuradas y tolerante a mayúsculas/minúsculas para BLUMCL, BLUMSEC y BLUMELIX |
| `blumix development` | Disponibilidad de herramientas de desarrollo |
| `blumix status` | Resumen breve del equipo y las rutas |
| `blumix doctor` | Comprobaciones básicas de instalación |
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
./bin/blumix system
~~~

Para ejecutar sin instalar nada en el sistema, utiliza `./bin/blumix` desde el repositorio. Si deseas el comando global, añade el directorio `bin` de tu copia local al PATH; no pegues una ruta de otra máquina sin revisarla.

## Configuración

Copia la plantilla y edita las rutas de acuerdo con tu equipo:

~~~bash
cp config/blumix.conf.example config/blumix.conf
nano config/blumix.conf
~~~

Puedes definir `BLUMCL_HOME`, `BLUMSEC_HOME` y `BLUMELIX_HOME` como rutas absolutas. También se pueden pasar como variables de entorno para una ejecución. El archivo local `config/blumix.conf` está excluido de Git.

**Seguridad de configuración:** el archivo se carga como código Bash. Solo uses archivos que tú hayas creado o revisado; nunca cargues una configuración de una fuente no confiable.

## Principios de diseño

- **Unificado, no fusionado:** cada herramienta conserva su repositorio e identidad.
- **Lectura primero:** las comprobaciones no cambian firewall, servicios ni archivos.
- **Sin secretos en Git:** credenciales, claves y configuración local no deben versionarse.
- **Offline-first:** las funciones de diagnóstico local no necesitan IA ni servicios externos.
- **IA opcional:** no es requisito de instalación ni se activa por defecto.
- **Honestidad de estado:** “directorio encontrado” no significa que una integración esté conectada ni que el servicio esté saludable.

## Calidad y seguridad

~~~bash
bash tests/test_blumix.sh
bash -n bin/blumix
for file in lib/*.sh; do bash -n "$file" || exit 1; done
~~~

Consulta [la arquitectura](docs/architecture/overview.md), [la instalación](docs/guides/installation.md), [la política de seguridad](SECURITY.md), [las contribuciones](CONTRIBUTING.md), el [changelog](CHANGELOG.md) y el [roadmap](ROADMAP.md).

## Licencia

MIT, según el archivo LICENSE del repositorio.
