# BLUMIX Atlas: arquitectura de operaciones privilegiadas

## Objetivo

BLUMIX es el plano de control del ecosistema. Coordina el descubrimiento y la operación de proyectos independientes; no absorbe sus repositorios ni declara salud a partir de la existencia de una carpeta.

El Atlas nuevo representa topología, evidencia, eventos, políticas y acciones. Su vista de estado se mantiene en modo solo lectura hasta que exista un agente local autenticado. La interfaz por sí sola nunca ejecuta comandos de sistema.

## Estado implementado

- Nuevo diseño de Atlas con mapa SVG accesible, navegación por vistas, registro de eventos, tarjetas de integraciones, métricas de instantánea y consola que prepara comandos para ejecución manual.
- Importación local de `blumix.snapshot.v1`, con límite de tamaño y validación de tipos, rangos y coherencia.
- Comando `blumix policy` / `blumix policy --json`, con esquema `blumix.policy.v1`.
- Política `default_deny: true`; reinicios y cambios privilegiados bloqueados, shell arbitraria denegada.
- El catálogo no invoca sudo, no ejecuta operaciones y no contacta la red.

## Modelo de capacidades

| Capacidad | Estado | Principio |
| --- | --- | --- |
| `inspect_system` | Disponible | Lectura local; no requiere elevación. |
| `inspect_integrations` | Disponible | Detecta directorios; no prueba salud del servicio. |
| `inspect_security` | Disponible | Diagnóstico; no aplica cambios. |
| `restart_service` | Bloqueada | Futuro: solo servicios enumerados en política, autenticación y aprobación por acción. |
| `apply_system_change` | Bloqueada | Futuro: plan revisable, alcance limitado, autorización, comprobación posterior y reversión si procede. |
| `run_shell` | Denegada | No se expone una shell arbitraria como API. |

## Diseño requerido antes de habilitar privilegios

1. **Agente local mínimo:** servicio separado del navegador, escuchando solo en socket Unix local con permisos estrictos. No debe escuchar en todas las interfaces de red.
2. **Identidad del cliente:** autenticar a los clientes autorizados; no confiar en que una petición venga de una página local o de un origen web conocido.
3. **Protocolo tipado:** operaciones con identificadores enumerados y esquemas de argumentos estrictos. Rechazar claves desconocidas, argumentos extra, rutas libres y valores fuera de rango.
4. **Autorización independiente:** lista permitida de operaciones y parámetros. El agente valida la política de nuevo aunque la UI ya haya validado la petición.
5. **Aprobación por operación:** mostrar acción, recurso exacto, impacto, duración y plan de reversión; aprobación de un solo uso con caducidad. No usar una autorización global persistente.
6. **Privilegio mínimo:** preferir operaciones no privilegiadas. Si se necesita elevación, usar reglas específicas de `sudoers` o un helper pequeño y auditado; nunca conceder shell root ni `sudo NOPASSWD: ALL`.
7. **Protección contra repetición:** nonce, identificador de petición, expiración y estado de ejecución. Rechazar peticiones caducadas o repetidas.
8. **Registro de auditoría:** guardar actor, operación, parámetros redactados, autorización, resultado, hora y código de salida. No registrar secretos. Detectar errores de escritura y almacenamiento.
9. **Ejecución acotada:** timeout, límites de salida, entorno limpio, rutas absolutas fijas para binarios y descriptores cerrados. Nunca construir comandos concatenando cadenas.
10. **Verificación posterior:** comprobar el estado real después de la acción y devolver evidencia, no solo un mensaje de éxito.
11. **Despliegue seguro:** cabeceras CSP, evitar scripts remotos, proteger contra CSRF si hay HTTP, restringir CORS y no exponer el socket a la red.
12. **Pruebas de abuso:** argumentos maliciosos, repetición, falta de autorización, cliente no confiable, timeouts, binarios ausentes, permisos incorrectos y fallo de reversión.

## Fronteras de confianza

- **Navegador/Atlas:** presentación e importación local; no es una autoridad de seguridad.
- **CLI:** comandos locales verificables y explícitos.
- **Agente futuro:** valida cada petición y aplica políticas; no se considera confiable por el mero hecho de ejecutarse en localhost.
- **Proyectos integrados:** cada uno conserva su propia configuración, autenticación, datos y ciclo de vida.
- **Informes JSON:** datos no firmados. Validar esquema no demuestra procedencia ni autenticidad.

## Lo que no se debe afirmar

No se promete un sistema “infranqueable”. No se muestra una integración como sana sin prueba, no se marca una operación como ejecutada si no se ejecutó y no se activa una función privilegiada antes de que el agente, la política y las pruebas de abuso estén implementados.
