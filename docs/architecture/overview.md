# Arquitectura de BLUMIX

## Propósito

BLUMIX es un dispatcher de terminal con módulos Bash. Presenta diagnósticos locales y descubre directorios configurados para herramientas relacionadas. No fusiona los repositorios ni debe ejecutar acciones modificadoras sin una confirmación explícita futura.

## Flujo

~~~text
Usuario
  |
  v
bin/blumix  -> valida comando / muestra ayuda
  |
  +--> lib/core.sh          rutas, utilidades, configuración local
  +--> lib/ui.sh            presentación y métricas de terminal
  +--> lib/system.sh        información del sistema
  +--> lib/network.sh       interfaces y DNS local
  +--> lib/security.sh      observaciones de firewall y SSH
  +--> lib/integrations.sh  descubrimiento de directorios
  +--> lib/development.sh   herramientas disponibles
~~~

## Estructura

~~~text
Blumix/
├── bin/blumix
├── lib/
│   ├── core.sh
│   ├── ui.sh
│   ├── system.sh
│   ├── network.sh
│   ├── security.sh
│   ├── integrations.sh
│   └── development.sh
├── config/blumix.conf.example
├── docs/
│   └── visual-atlas/
├── tests/test_blumix.sh
├── README.md
├── SECURITY.md
├── CONTRIBUTING.md
├── ROADMAP.md
└── CHANGELOG.md
~~~

## Integraciones

Las variables de entorno `BLUMCL_HOME`, `BLUMSEC_HOME` y `BLUMELIX_HOME` apuntan a directorios independientes. BLUMIX intenta respetar las variables explícitas; si no existen, busca algunas rutas locales conocidas y conserva la ruta histórica como último recurso.

Una ruta encontrada solo demuestra que el directorio existe. No confirma que el proyecto esté instalado correctamente, que sus pruebas pasen, que su servicio esté activo o que exista una API conectada. Las integraciones profundas requieren adaptadores y contratos verificados por separado.

## Configuración

La configuración local opcional está en `config/blumix.conf` o en la ruta indicada por `BLUMIX_CONFIG`. Se carga como Bash y por ello solo deben usarse archivos locales confiables. No se guardan secretos ni tokens en el repositorio.

## Seguridad por diseño

- Diagnósticos en modo lectura.
- Sin elevación automática a root.
- Sin llamadas a servicios externos para las métricas locales.
- IA desactivada por defecto.
- Las comprobaciones informativas no sustituyen una auditoría completa.
- Los errores y los comandos desconocidos deben devolver estados de salida útiles.

## Límites actuales

La CLI no es todavía un gestor de servicios, un sistema de plugins, un escáner de puertos ni un panel de salud distribuido. Esos objetivos requieren diseño, pruebas y controles propios antes de anunciarlos como capacidades implementadas.
