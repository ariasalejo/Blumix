# BLUMIX · Atlas Visual

> Guía visual interactiva para entender BLUMIX como centro de mando sin fusionar los proyectos que coordina.

## Experiencia visual

La guía autónoma está en [`index.html`](./index.html) y ofrece:

- Mapa SVG de arquitectura con BLUMIX como núcleo y BLUMCL, BLUMSEC y BLUMELIX como proyectos separados.
- Tarjetas de responsabilidades con filtro interactivo.
- Dos recorridos: comprensión general y recorrido técnico.
- Flujo de trabajo: detectar → verificar → explicar → actuar.
- Principios de seguridad, separación de repositorios y trazabilidad.
- Hoja de ruta para evolucionar hacia un panel conectado a datos reales.

## Cómo abrirla

No requiere paquetes, servidor, claves API ni conexión a servicios externos para funcionar. Desde la raíz del repositorio:

```bash
xdg-open docs/visual-atlas/index.html
```

También puedes abrir el archivo directamente desde GitHub o descargarlo para uso local.

## Alcance y honestidad técnica

Esta primera versión es una guía estática e interactiva, no un dashboard en tiempo real. Los enlaces de GitHub llevan a rutas públicas; no se consultan APIs ni se ejecutan comandos en tu equipo. Los proyectos aparecen porque están mencionados en la documentación/configuración existente del repositorio, pero cada integración debe verificarse antes de marcarse como operativa.

## Siguiente evolución recomendada

1. Inventariar repositorios y rutas locales reales, en modo lectura.
2. Añadir un manifiesto versionado con nombre, propósito, URL, rama principal, estado de pruebas y responsable por proyecto.
3. Conectar GitHub con permisos mínimos y sin exponer tokens.
4. Mostrar datos con fecha de actualización y etiquetas `detectado`, `configurado`, `probado` y `pendiente`.
5. Añadir pruebas de accesibilidad, responsive y enlaces; documentar despliegue solo después de validar el stack real.

## Reglas de seguridad

- No mezclar el código ni la historia Git de proyectos independientes.
- No sobrescribir archivos existentes sin inspección y autorización.
- No registrar secretos, claves API, tokens ni datos de bóvedas.
- No afirmar que un sistema está activo si solo existe una referencia documental.
- Mantener cada proyecto con sus propias pruebas, versiones y ciclo de publicación.
