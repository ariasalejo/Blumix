# BLUMIX Brain — contrato de ingeniería

## Propósito

BLUMIX es un plano de control local-first para observar el equipo y coordinar proyectos independientes sin fusionar sus repositorios. El cerebro combina reglas deterministas explicables con una red neuronal experimental pequeña, implementada con Python estándar.

La promesa del producto no es “adivinar mejor”: es explicar qué se observó, de dónde salió, qué sigue desconocido y qué necesita revisión humana.

## Arquitectura

1. **Captura (`blumix.snapshot.v1`)**: mediciones locales de la máquina y presencia de directorios. La instantánea no contiene rutas absolutas ni secretos.
2. **Adaptador (`brain/evidence.py`)**: valida el esquema y convierte porcentajes observados a valores normalizados 0–1.
3. **Evidencia (`blumix.brain.evidence.v1`)**: conserva fuente, valor bruto, normalización, señales desconocidas y límites de seguridad.
4. **Razonador determinista (`brain/reasoning.py`)**: aplica reglas y pesos explícitos; cada hallazgo debe poder explicarse.
5. **MLP experimental (`brain/network.py`)**: motor didáctico pequeño; no es una probabilidad calibrada ni se activa automáticamente.
6. **Atlas (`docs/visual-atlas/index.html`)**: presenta evidencia importada por el operador en el navegador, sin transmitir el archivo ni ejecutar inferencia neuronal.

## Invariantes obligatorios

- **UNKNOWN no es cero.** Si una medición o resultado no existe, se mantiene `null` / `UNKNOWN`.
- No se inventan fallos de dependencias ni de pruebas. La instantánea actual no contiene resultados de esos procesos.
- Las reglas y la salida neuronal deben diferenciarse. Una puntuación no es una probabilidad salvo calibración y validación externa.
- No se ejecutan comandos de sistema, no se reinician servicios y no se cambia configuración desde el motor.
- No se envían datos a servicios externos ni se añaden dependencias de Python para el cerebro.
- Los modelos/datasets no se reemplazan por defecto. Cualquier entrenamiento usa datasets etiquetados explícitamente.
- La presencia de un directorio no demuestra que el servicio esté sano.
- Toda vista de informes debe indicar procedencia, momento de captura y que el JSON no está firmado.
- La interfaz debe usar texto insertado de forma segura (por ejemplo, `textContent`, no HTML dinámico con datos externos).
- El consentimiento humano no se infiere de un clic en un panel de diagnóstico.

## Cómo trabajar con un asistente de código

Antes de editar: leer el archivo completo, el estado Git y las pruebas relacionadas. Hacer cambios acotados, añadir pruebas, revisar el diff y explicar cualquier limitación. No sobrescribir artefactos locales sin seguimiento ni renombrar BLUMIX a BLUM/BlumHelps/BlumTherapy. Mantener `QWEN.md` y `bin/levantar-demo.sh` locales intactos hasta una integración explícita que preserve su contenido.

## Próximos hitos

- Añadir evidencia verificable y versionada de dependencias y pruebas, con identificador de ejecución, fecha, comando autorizado, código de salida y procedencia.
- Validar datasets con separación entre entrenamiento y evaluación; publicar métricas de validación, no solo error de entrenamiento.
- Añadir pruebas de accesibilidad y de seguridad del Atlas.
- Diseñar un registro append-only de eventos antes de cualquier capacidad de operación.
- Mantener las operaciones mutables deshabilitadas hasta que exista un agente local autenticado y un protocolo de aprobación explícito.

## Comandos seguros de observación

```bash
./bin/blumix report --json > /tmp/blumix-snapshot.json
./bin/blumix brain observe --snapshot /tmp/blumix-snapshot.json
python3 tests/test_brain.py
```

La salida de `brain observe` es evidencia normalizada, no una predicción y no una autorización para actuar.
