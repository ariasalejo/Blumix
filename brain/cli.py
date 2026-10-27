#!/usr/bin/env python3
"""Command-line entry point for BLUMIX's experimental local brain."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
    from brain.network import BrainDataError, FEATURE_NAMES, load_dataset, load_model, predict, save_model, train
    from brain.reasoning import analyze_features
else:
    from .network import BrainDataError, FEATURE_NAMES, load_dataset, load_model, predict, save_model, train
    from .reasoning import analyze_features


DEMO_SAMPLES = [
    ({"cpu_pressure": 0.05, "memory_pressure": 0.10, "disk_pressure": 0.10, "dependency_failures": 0.0, "test_failures": 0.0}, 0.05),
    ({"cpu_pressure": 0.15, "memory_pressure": 0.20, "disk_pressure": 0.15, "dependency_failures": 0.0, "test_failures": 0.0}, 0.10),
    ({"cpu_pressure": 0.35, "memory_pressure": 0.45, "disk_pressure": 0.25, "dependency_failures": 0.1, "test_failures": 0.1}, 0.30),
    ({"cpu_pressure": 0.55, "memory_pressure": 0.60, "disk_pressure": 0.50, "dependency_failures": 0.4, "test_failures": 0.3}, 0.55),
    ({"cpu_pressure": 0.75, "memory_pressure": 0.80, "disk_pressure": 0.75, "dependency_failures": 0.7, "test_failures": 0.6}, 0.78),
    ({"cpu_pressure": 0.95, "memory_pressure": 0.95, "disk_pressure": 0.90, "dependency_failures": 1.0, "test_failures": 1.0}, 0.98),
]


def _read_features(path: str) -> dict[str, Any]:
    try:
        with open(path, encoding="utf-8") as stream:
            data = json.load(stream)
    except (OSError, json.JSONDecodeError) as exc:
        raise BrainDataError(f"No se pudo leer el JSON de features: {exc}") from exc
    if isinstance(data, dict) and "features" in data:
        data = data["features"]
    if not isinstance(data, dict):
        raise BrainDataError("El archivo de features debe contener un objeto JSON.")
    return data


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="blumix brain", description="Motor experimental de razonamiento neuronal BLUMIX.")
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("status", help="mostrar estado y límites del motor")
    demo = commands.add_parser("demo", help="entrenar en memoria con datos sintéticos de demostración")
    demo.add_argument("--epochs", type=int, default=600)
    fit = commands.add_parser("train", help="entrenar con un dataset etiquetado por el usuario")
    fit.add_argument("--dataset", required=True, help="JSON con schema blumix.brain.dataset.v1")
    fit.add_argument("--output", required=True, help="ruta de salida del modelo JSON")
    fit.add_argument("--epochs", type=int, default=500)
    fit.add_argument("--learning-rate", type=float, default=0.2)
    fit.add_argument("--seed", type=int, default=7)
    fit.add_argument("--force", action="store_true", help="autorizar reemplazo de un archivo de modelo existente")
    analyze = commands.add_parser("analyze", help="comparar reglas transparentes y, opcionalmente, una red neuronal")
    analyze.add_argument("--features", required=True, help="JSON con los cinco features normalizados")
    analyze.add_argument("--model", help="modelo neuronal opcional para comparar resultados")
    infer = commands.add_parser("predict", help="calcular una puntuación con un modelo entrenado")
    infer.add_argument("--model", required=True)
    infer.add_argument("--features", required=True, help="JSON con los cinco features normalizados entre 0 y 1")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = _parser()
    args = parser.parse_args(argv)
    try:
        if args.command == "status":
            print("BLUMIX BRAIN · EXPERIMENTAL")
            print("Algoritmo: MLP propio de una capa oculta; Python estándar, sin dependencias externas.")
            print("Features: " + ", ".join(FEATURE_NAMES))
            print("Estado: motor implementado; modelo operativo validado y datos reales aún no configurados.")
            print("Límites: no controla servicios, no ejecuta comandos y no autoriza acciones.")
            print("Las puntuaciones no son probabilidades clínicas ni certificaciones de salud del sistema.")
            return 0
        if args.command == "demo":
            if not 1 <= args.epochs <= 10000:
                raise BrainDataError("epochs debe estar entre 1 y 10000.")
            samples = [(list(sample[name] for name in FEATURE_NAMES), target) for sample, target in DEMO_SAMPLES]
            model = train(samples, epochs=args.epochs, seed=7)
            example = DEMO_SAMPLES[-2][0]
            score = predict(model, example)
            print("BLUMIX BRAIN · DEMOSTRACIÓN AISLADA")
            print("ADVERTENCIA: datos sintéticos didácticos; no representan equipos ni incidentes reales.")
            print(f"Arquitectura: 5 → {model['hidden_size']} → 1 · épocas: {args.epochs}")
            print(f"Error cuadrático medio de entrenamiento: {model['metadata']['training_mse']}")
            print(f"Puntuación de ejemplo (0–1): {score:.4f}")
            print("No se guardó ningún archivo y no se ejecutó ninguna acción externa.")
            return 0
        if args.command == "analyze":
            features = _read_features(args.features)
            result = {"schema": "blumix.brain.analysis.v1", "deterministic": analyze_features(features), "neural": None, "comparison": "rules_only", "action_taken": False}
            if args.model:
                model = load_model(args.model)
                neural_score = predict(model, features)
                rule_score = result["deterministic"]["score"]
                result["neural"] = {"algorithm": model["algorithm"], "score": round(neural_score, 6), "model_state": model.get("metadata", {}).get("state", "unknown")}
                difference = abs(rule_score - neural_score)
                result["comparison"] = {"absolute_score_difference": round(difference, 6), "status": "REVIEW_REQUIRED" if difference >= 0.25 else "NO_LARGE_DISAGREEMENT_DETECTED", "threshold": 0.25}
            print(json.dumps(result, ensure_ascii=False, indent=2))
            return 0
        if args.command == "train":
            samples = load_dataset(args.dataset)
            model = train(samples, epochs=args.epochs, learning_rate=args.learning_rate, seed=args.seed)
            save_model(model, args.output, force=args.force)
            print("Modelo experimental entrenado y guardado.")
            print(f"Archivo: {args.output}")
            print(f"Muestras: {model['metadata']['sample_count']} · épocas: {args.epochs}")
            print(f"Error de entrenamiento (MSE): {model['metadata']['training_mse']}")
            print("VALIDACIÓN PENDIENTE: el error mostrado es sobre los datos de entrenamiento.")
            print("El modelo no se activa automáticamente ni puede ejecutar acciones.")
            return 0
        if args.command == "predict":
            model = load_model(args.model)
            features = _read_features(args.features)
            score = predict(model, features)
            print(json.dumps({
                "schema": "blumix.brain.prediction.v1",
                "model_schema": model["schema"],
                "score": round(score, 6),
                "score_range": [0, 1],
                "meaning": "puntuación aprendida; su interpretación depende de las etiquetas del dataset",
                "model_state": model.get("metadata", {}).get("state", "unknown"),
                "action_taken": False,
            }, ensure_ascii=False, indent=2))
            return 0
    except BrainDataError as exc:
        print(f"BLUMIX BRAIN: {exc}", file=sys.stderr)
        return 2
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
