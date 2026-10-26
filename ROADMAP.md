# Roadmap de BLUMIX

Este roadmap diferencia la base existente de las mejoras propuestas. Una casilla solo debe marcarse como completada cuando el cambio exista y haya evidencia de prueba.

## Etapa 1 — Confiabilidad de la CLI
- [x] Dispatcher modular en Bash.
- [x] Comandos de diagnóstico básicos.
- [x] Ayuda explícita y error para comandos desconocidos.
- [x] Comprobación local inicial (`doctor`).
- [x] Pruebas de sintaxis y contratos básicos de CLI.
- [ ] Probar en Ubuntu/Lubuntu, Debian y Termux.
- [ ] Cobertura de terminales estrechas, salida no interactiva y ausencia de dependencias opcionales.

## Etapa 2 — Seguridad y configuración
- [x] Diagnósticos de solo lectura.
- [x] Distinguir “no detectado” de “inactivo” en verificaciones básicas.
- [x] Configuración local excluida de Git y advertencia de que se interpreta como Bash.
- [ ] Validar con ShellCheck y añadirlo a CI.
- [ ] Revisar carga de configuración, permisos, enlaces simbólicos y valores inesperados.
- [ ] Crear matriz de amenazas y política de retención si se agregan informes.

## Etapa 3 — Integraciones verificables
- [x] Mostrar las tres rutas configuradas.
- [x] Indicar que encontrar una carpeta no prueba salud del proyecto.
- [ ] Definir adaptadores versionados por proyecto.
- [ ] Detectar Git, versión y estado de pruebas sin modificar repositorios.
- [ ] Conectar servicios solo mediante interfaces documentadas y credenciales externas al repositorio.

## Etapa 4 — Calidad de ingeniería
- [x] Ejecutar pruebas básicas con Bash.
- [ ] CI con ShellCheck y pruebas en varias distribuciones.
- [ ] Matriz de compatibilidad y pruebas de regresión.
- [ ] Versionado semántico y política de releases.
- [ ] Revisar accesibilidad de salida, colores y modo sin animación.

## Etapa 5 — Centro de mando
- [x] Atlas visual estático e interactivo.
- [ ] Catálogo de módulos basado en metadatos verificables.
- [ ] Exportación local de diagnósticos con consentimiento.
- [ ] Historial opcional con límites de privacidad y rotación.
- [ ] Modo JSON estable para automatización.

## Etapa 6 — Capacidades futuras (no implementadas)
- [ ] Plugins con contrato, permisos y pruebas.
- [ ] Integración con IA local opcional con límites de recursos.
- [ ] Acciones de administración detrás de confirmación explícita.
- [ ] Instalador reversible y comprobaciones de integridad.

## Criterios para declarar una versión estable

- Las pruebas automatizadas pasan.
- La documentación coincide con el comportamiento real.
- La instalación funciona en entornos documentados.
- No se incluyen secretos, datos personales ni rutas específicas del autor como requisito.
- Cada capacidad tiene límites y mensajes de error claros.
