"""Small feed-forward neural network implemented with the Python standard library.

This module learns a bounded score from user-labelled, normalized examples.
"""
from __future__ import annotations

import json
import math
import os
import random
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SCHEMA_DATASET = "blumix.brain.dataset.v1"
SCHEMA_MODEL = "blumix.brain.model.v1"
FEATURE_NAMES = (
    "cpu_pressure",
    "memory_pressure",
    "disk_pressure",
    "dependency_failures",
    "test_failures",
)


class BrainDataError(ValueError):
    """Raised when a dataset or model is malformed or unsafe to use."""


def _number(value: Any, label: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise BrainDataError(f"{label}: se esperaba un número.")
    result = float(value)
    if not math.isfinite(result) or not 0.0 <= result <= 1.0:
        raise BrainDataError(f"{label}: el valor debe ser finito y estar entre 0 y 1.")
    return result


def validate_features(value: Any) -> list[float]:
    if not isinstance(value, dict):
        raise BrainDataError("features debe ser un objeto JSON.")
    missing = set(FEATURE_NAMES) - set(value)
    extra = set(value) - set(FEATURE_NAMES)
    if missing or extra:
        details = []
        if missing:
            details.append("faltan: " + ", ".join(sorted(missing)))
        if extra:
            details.append("desconocidas: " + ", ".join(sorted(extra)))
        raise BrainDataError("Campos de features inválidos (" + "; ".join(details) + ").")
    return [_number(value[name], name) for name in FEATURE_NAMES]


def load_dataset(path: str | Path) -> list[tuple[list[float], float]]:
    try:
        with open(path, encoding="utf-8") as stream:
            document = json.load(stream)
    except (OSError, json.JSONDecodeError) as exc:
        raise BrainDataError(f"No se pudo leer el dataset JSON: {exc}") from exc
    if not isinstance(document, dict) or document.get("schema") != SCHEMA_DATASET:
        raise BrainDataError(f"El dataset debe declarar schema={SCHEMA_DATASET}.")
    samples = document.get("samples")
    if not isinstance(samples, list) or len(samples) < 4:
        raise BrainDataError("Se requieren al menos 4 muestras etiquetadas.")
    result: list[tuple[list[float], float]] = []
    for index, sample in enumerate(samples, start=1):
        if not isinstance(sample, dict) or "features" not in sample or "target" not in sample:
            raise BrainDataError(f"Muestra {index}: se requieren features y target.")
        result.append((validate_features(sample["features"]), _number(sample["target"], f"muestra {index} target")))
    if len({target for _, target in result}) < 2:
        raise BrainDataError("El dataset necesita al menos dos valores target distintos.")
    return result


def _sigmoid(value: float) -> float:
    if value >= 0:
        z = math.exp(-min(value, 700.0))
        return 1.0 / (1.0 + z)
    z = math.exp(max(value, -700.0))
    return z / (1.0 + z)


def _forward(model: dict[str, Any], inputs: list[float]) -> tuple[list[float], float]:
    hidden = [
        _sigmoid(sum(weight * value for weight, value in zip(row, inputs)) + bias)
        for row, bias in zip(model["weights_input_hidden"], model["bias_hidden"])
    ]
    output = _sigmoid(sum(weight * value for weight, value in zip(model["weights_hidden_output"][0], hidden))
                      + model["bias_output"][0])
    return hidden, output


def new_model(hidden_size: int = 6, seed: int = 7) -> dict[str, Any]:
    if not 1 <= hidden_size <= 32:
        raise BrainDataError("hidden_size debe estar entre 1 y 32.")
    rng = random.Random(seed)
    return {
        "schema": SCHEMA_MODEL,
        "algorithm": "BLUMIX-MLP-1H-SIGMOID-BACKPROP",
        "feature_names": list(FEATURE_NAMES),
        "hidden_size": hidden_size,
        "weights_input_hidden": [
            [rng.uniform(-0.5, 0.5) for _ in FEATURE_NAMES] for _ in range(hidden_size)
        ],
        "bias_hidden": [0.0 for _ in range(hidden_size)],
        "weights_hidden_output": [[rng.uniform(-0.5, 0.5) for _ in range(hidden_size)]],
        "bias_output": [0.0],
        "metadata": {"state": "untrained", "seed": seed},
    }


def predict(model: dict[str, Any], features: dict[str, Any]) -> float:
    validate_model(model)
    inputs = validate_features(features)
    return _forward(model, inputs)[1]


def train(
    samples: list[tuple[list[float], float]],
    *,
    epochs: int = 500,
    learning_rate: float = 0.2,
    seed: int = 7,
    hidden_size: int = 6,
) -> dict[str, Any]:
    if len(samples) < 4:
        raise BrainDataError("Se requieren al menos 4 muestras para entrenar.")
    if not 1 <= epochs <= 10000:
        raise BrainDataError("epochs debe estar entre 1 y 10000.")
    if not math.isfinite(learning_rate) or not 0.001 <= learning_rate <= 1.0:
        raise BrainDataError("learning_rate debe estar entre 0.001 y 1.")
    checked = [(list(_number(v, "feature") for v in x), _number(y, "target")) for x, y in samples]
    if any(len(x) != len(FEATURE_NAMES) for x, _ in checked):
        raise BrainDataError("Todas las muestras deben tener el número correcto de features.")
    if len({target for _, target in checked}) < 2:
        raise BrainDataError("El dataset necesita al menos dos valores target distintos.")

    model = new_model(hidden_size=hidden_size, seed=seed)
    rng = random.Random(seed + 1)
    for _ in range(epochs):
        order = list(range(len(checked)))
        rng.shuffle(order)
        for index in order:
            inputs, target = checked[index]
            hidden, output = _forward(model, inputs)
            delta_out = (output - target) * output * (1.0 - output)
            old_output_weights = list(model["weights_hidden_output"][0])
            delta_hidden = [
                delta_out * old_output_weights[j] * hidden[j] * (1.0 - hidden[j])
                for j in range(hidden_size)
            ]
            for j in range(hidden_size):
                model["weights_hidden_output"][0][j] -= learning_rate * delta_out * hidden[j]
            model["bias_output"][0] -= learning_rate * delta_out
            for j in range(hidden_size):
                for k in range(len(FEATURE_NAMES)):
                    model["weights_input_hidden"][j][k] -= learning_rate * delta_hidden[j] * inputs[k]
                model["bias_hidden"][j] -= learning_rate * delta_hidden[j]

    predictions = [_forward(model, features)[1] for features, _ in checked]
    mse = sum((prediction - target) ** 2 for prediction, (_, target) in zip(predictions, checked)) / len(checked)
    model["metadata"] = {
        "state": "trained_experimental",
        "seed": seed,
        "sample_count": len(checked),
        "epochs": epochs,
        "learning_rate": learning_rate,
        "training_mse": round(mse, 8),
        "trained_at": datetime.now(timezone.utc).isoformat(),
        "validation": "in-sample only; independent validation dataset still required",
    }
    validate_model(model)
    return model


def validate_model(model: Any) -> None:
    if not isinstance(model, dict) or model.get("schema") != SCHEMA_MODEL:
        raise BrainDataError(f"Modelo inválido: se requiere schema={SCHEMA_MODEL}.")
    if model.get("feature_names") != list(FEATURE_NAMES):
        raise BrainDataError("El modelo no coincide con el contrato de features BLUMIX.")
    hidden_size = model.get("hidden_size")
    if isinstance(hidden_size, bool) or not isinstance(hidden_size, int) or not 1 <= hidden_size <= 32:
        raise BrainDataError("hidden_size inválido.")
    dimensions = (
        ("weights_input_hidden", hidden_size, len(FEATURE_NAMES)),
        ("weights_hidden_output", 1, hidden_size),
        ("bias_hidden", 1, hidden_size),
        ("bias_output", 1, 1),
    )
    for key, rows, columns in dimensions:
        value = model.get(key)
        if key.startswith("bias_"):
            if not isinstance(value, list) or len(value) != columns:
                raise BrainDataError(f"Dimensiones inválidas en {key}.")
            flat = value
        else:
            if not isinstance(value, list) or len(value) != rows or any(
                not isinstance(row, list) or len(row) != columns for row in value
            ):
                raise BrainDataError(f"Dimensiones inválidas en {key}.")
            flat = [item for row in value for item in row]
        if any(isinstance(item, bool) or not isinstance(item, (int, float)) or not math.isfinite(item) for item in flat):
            raise BrainDataError(f"Valores numéricos inválidos en {key}.")
    if not isinstance(model.get("metadata"), dict):
        raise BrainDataError("Faltan metadatos del modelo.")


def save_model(model: dict[str, Any], path: str | Path, *, force: bool = False) -> None:
    validate_model(model)
    destination = Path(path)
    if destination.exists() and not force:
        raise BrainDataError(f"El archivo ya existe: {destination}. Usa --force para reemplazarlo explícitamente.")
    if not destination.parent.is_dir():
        raise BrainDataError(f"No existe el directorio de destino: {destination.parent}")
    payload = json.dumps(model, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    temp_name = None
    try:
        with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=destination.parent,
                                         prefix=".blumix-model-", delete=False) as stream:
            temp_name = stream.name
            stream.write(payload)
            stream.flush()
            os.fsync(stream.fileno())
        if destination.exists() and not force:
            raise BrainDataError(f"El archivo ya existe: {destination}. No se sobrescribió.")
        os.replace(temp_name, destination)
    finally:
        if temp_name and os.path.exists(temp_name):
            os.unlink(temp_name)


def load_model(path: str | Path) -> dict[str, Any]:
    try:
        with open(path, encoding="utf-8") as stream:
            model = json.load(stream)
    except (OSError, json.JSONDecodeError) as exc:
        raise BrainDataError(f"No se pudo leer el modelo JSON: {exc}") from exc
    validate_model(model)
    return model
