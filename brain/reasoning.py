"""Transparent, deterministic baseline for BLUMIX Brain.

This baseline is intentionally interpretable and is not statistically calibrated.
"""
from __future__ import annotations

from typing import Any

from .network import FEATURE_NAMES, BrainDataError, validate_features

WEIGHTS = {
    "cpu_pressure": 0.15,
    "memory_pressure": 0.20,
    "disk_pressure": 0.15,
    "dependency_failures": 0.25,
    "test_failures": 0.25,
}


def analyze_features(features: dict[str, Any]) -> dict[str, Any]:
    values = validate_features(features)
    normalized = dict(zip(FEATURE_NAMES, values))
    score = sum(normalized[name] * WEIGHTS[name] for name in FEATURE_NAMES)
    findings = []
    for name in ("cpu_pressure", "memory_pressure", "disk_pressure"):
        if normalized[name] >= 0.85:
            findings.append({"feature": name, "level": "high", "evidence": "normalized input >= 0.85"})
        elif normalized[name] >= 0.70:
            findings.append({"feature": name, "level": "review", "evidence": "normalized input >= 0.70"})
    for name in ("dependency_failures", "test_failures"):
        if normalized[name] > 0:
            findings.append({"feature": name, "level": "present", "evidence": "normalized input > 0"})
    if score >= 0.75:
        state = "HIGH_REVIEW"
    elif score >= 0.40:
        state = "REVIEW"
    else:
        state = "LOWER_SIGNAL"
    return {
        "algorithm": "BLUMIX-EXPLICIT-WEIGHTED-RULES-1",
        "score": round(score, 6),
        "state": state,
        "weights": WEIGHTS.copy(),
        "findings": findings,
        "limitations": [
            "Heurística explícita diseñada por el proyecto; no calibrada estadísticamente.",
            "Las entradas deben proceder de evidencia real y una normalización documentada.",
            "No demuestra salud ni causa raíz y no autoriza acciones.",
        ],
    }
