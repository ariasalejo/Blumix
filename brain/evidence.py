"""Convert a BLUMIX system snapshot into evidence-aware brain inputs.

This adapter is deliberately read-only. Missing signals stay unknown (None);
they are never fabricated to make a model prediction possible.
"""
from __future__ import annotations

import json
import math
from pathlib import Path
from typing import Any

from .network import FEATURE_NAMES, BrainDataError

SCHEMA_SNAPSHOT = "blumix.snapshot.v1"
SCHEMA_EVIDENCE = "blumix.brain.evidence.v1"

METRIC_MAP = {
    "cpu_pressure": ("system.cpu_percent", "cpu_percent"),
    "memory_pressure": ("system.memory_percent", "memory_percent"),
    "disk_pressure": ("system.root_disk_percent", "root_disk_percent"),
}


def _normalized_percent(value: Any, field: str) -> float | None:
    if value is None:
        return None
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise BrainDataError(f"{field} debe ser un número entre 0 y 100 o null.")
    if not math.isfinite(value) or not 0 <= value <= 100:
        raise BrainDataError(f"{field} debe estar entre 0 y 100.")
    return round(float(value) / 100.0, 6)


def build_evidence(snapshot: Any) -> dict[str, Any]:
    """Validate a snapshot and map only supported measurements to normalized inputs."""
    if not isinstance(snapshot, dict):
        raise BrainDataError("La instantánea debe ser un objeto JSON.")
    if snapshot.get("schema") != SCHEMA_SNAPSHOT:
        raise BrainDataError(f"Esquema incompatible; se requiere {SCHEMA_SNAPSHOT}.")
    system = snapshot.get("system")
    if not isinstance(system, dict):
        raise BrainDataError("La instantánea no contiene un objeto system válido.")

    features: dict[str, float | None] = {name: None for name in FEATURE_NAMES}
    observations: dict[str, dict[str, Any]] = {}
    for feature, (source_path, source_key) in METRIC_MAP.items():
        normalized = _normalized_percent(system.get(source_key), source_path)
        features[feature] = normalized
        observations[feature] = {
            "status": "OBSERVED" if normalized is not None else "UNKNOWN",
            "source": source_path,
            "raw_value": system.get(source_key),
            "unit": "percent",
            "normalized_value": normalized,
            "normalization": "percent / 100",
        }

    # The snapshot schema has no validated dependency/test outcomes. Keep them unknown.
    for feature in ("dependency_failures", "test_failures"):
        observations[feature] = {
            "status": "UNKNOWN",
            "source": None,
            "raw_value": None,
            "unit": None,
            "normalized_value": None,
            "reason": "La instantánea blumix.snapshot.v1 no contiene esta señal.",
        }

    missing = [name for name in FEATURE_NAMES if features[name] is None]
    return {
        "schema": SCHEMA_EVIDENCE,
        "source_schema": SCHEMA_SNAPSHOT,
        "source_generated_at": snapshot.get("generated_at"),
        "features": features,
        "observations": observations,
        "missing_features": missing,
        "ready_for_model": not missing,
        "action_taken": False,
        "safety": {
            "read_only": True,
            "network_access": False,
            "writes_files": False,
            "absolute_paths_included": False,
            "secrets_included": False,
        },
        "limitations": [
            "Solo se normalizan métricas presentes en la instantánea validada.",
            "Los fallos de dependencias y pruebas permanecen UNKNOWN hasta disponer de evidencia verificable.",
            "No se ejecuta inferencia neuronal ni se autoriza ninguna acción.",
        ],
    }


def load_snapshot(path: str | Path) -> dict[str, Any]:
    try:
        with open(path, encoding="utf-8") as stream:
            snapshot = json.load(stream)
    except (OSError, json.JSONDecodeError) as exc:
        raise BrainDataError(f"No se pudo leer la instantánea JSON: {exc}") from exc
    if not isinstance(snapshot, dict):
        raise BrainDataError("La instantánea debe contener un objeto JSON.")
    return build_evidence(snapshot)
