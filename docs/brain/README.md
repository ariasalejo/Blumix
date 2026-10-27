# BLUMIX Brain — motor neuronal experimental

## Propósito

La carpeta brain contiene una primera red neuronal implementada por el proyecto con la biblioteca estándar de Python. No descarga modelos, no requiere servicios externos y no ejecuta acciones del sistema. Es un componente experimental, no un agente autónomo ni una afirmación de que BLUMIX ya razone sobre todo el ecosistema.

## Motor de razonamiento determinista

brain/reasoning.py implementa una línea base transparente con pesos explícitos: CPU 0.15, memoria 0.20, disco 0.15, fallos de dependencias 0.25 y fallos de pruebas 0.25. Es una heurística diseñada por el proyecto, no una fórmula validada científicamente. Devuelve el detalle de las señales que superan umbrales configurados.

Analizar un archivo de features y, opcionalmente, comparar con un modelo neuronal:

    blumix brain analyze --features features.json
    blumix brain analyze --features features.json --model modelo.json

Si reglas y red neuronal difieren mucho, el resultado solicita revisión; no elige ni ejecuta una reparación automáticamente.

## Arquitectura propia

La versión inicial es un perceptrón multicapa (MLP) con cinco entradas, una capa oculta configurable (6 neuronas por defecto) y una salida sigmoide. La propagación hacia delante, la función sigmoide, la inicialización determinista, el cálculo del error y la retropropagación se implementan en brain/network.py. Los pesos se inicializan con una semilla reproducible y se ajustan durante el entrenamiento.

Entradas normalizadas, todas entre 0 y 1:

- cpu_pressure
- memory_pressure
- disk_pressure
- dependency_failures
- test_failures

La salida es una puntuación aprendida entre 0 y 1. No es automáticamente una probabilidad: su significado depende de cómo se hayan etiquetado los ejemplos del dataset. El motor no recopila esas señales por sí mismo todavía; el dataset debe ser preparado y revisado por una persona.

## Prueba de demostración

Desde la raíz del repositorio:

    python3 brain/cli.py status
    python3 brain/cli.py demo
    python3 tests/test_brain.py

El comando demo entrena en memoria con ejemplos sintéticos didácticos, muestra una predicción y no guarda archivos. Es una demostración del algoritmo, no un modelo útil para evaluar equipos reales.

## Dataset propio

El formato JSON usa el esquema blumix.brain.dataset.v1 y una lista samples. Cada muestra contiene un objeto features con los cinco campos y un target numérico entre 0 y 1. Un dataset de entrenamiento debe contener al menos cuatro muestras etiquetadas, con al menos dos valores target diferentes. Los valores deben ser finitos y normalizados. Las etiquetas deben definirse con criterios explícitos y evidencias auditables.

Entrenar requiere indicar un archivo de dataset y un destino:

    python3 brain/cli.py train --dataset /ruta/dataset.json --output /ruta/modelo.json

Si el destino ya existe, la operación se rechaza. El parámetro --force autoriza expresamente reemplazarlo. El entrenamiento muestra el error sobre los mismos datos usados para entrenar; eso no es validación independiente. Antes de usar un modelo para recomendaciones reales, debe evaluarse con datos separados y representativos.

Predicción con un modelo entrenado:

    python3 brain/cli.py predict --model /ruta/modelo.json --features /ruta/features.json

El archivo de features puede contener directamente el objeto features o un objeto con la propiedad features. Debe incluir exactamente los cinco campos.

## Límites de seguridad y calidad

- Sin red, dependencias de terceros, elevación de privilegios ni ejecución de comandos.
- Los modelos se guardan como JSON versionado y se validan antes de inferencia.
- No se sobrescribe un modelo existente sin --force.
- El motor no se activa automáticamente ni controla servicios.
- Una puntuación neuronal no reemplaza reglas deterministas, evidencias ni políticas.
- Los modelos reales deben tener versión, procedencia del dataset, criterios de etiquetado y validación independiente.
- Los siguientes pasos son conectar evidencia real mediante un adaptador tipado, comparar predicciones con reglas deterministas y medir errores antes de permitir que influyan en planes de actuación.

## Contrato del dataset

target representa la etiqueta que el responsable del dataset haya definido. Si se decide representar riesgo operativo, 0 debe significar riesgo mínimo y 1 riesgo máximo de forma consistente en todas las muestras. Las entradas son señales normalizadas, no métricas en unidades físicas. Documentar el método de normalización antes de entrenar.
