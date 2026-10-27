#!/usr/bin/env python3
"""Tests for BLUMIX's dependency-free neural engine."""
import contextlib
import io
import json
import tempfile
import unittest
from pathlib import Path

from brain.network import (
    BrainDataError, FEATURE_NAMES, SCHEMA_DATASET, load_dataset, load_model,
    new_model, predict, save_model, train, validate_features,
)
from brain.cli import main
from brain.reasoning import analyze_features


def features(level):
    return {
        "cpu_pressure": level,
        "memory_pressure": min(1.0, level * 0.95),
        "disk_pressure": min(1.0, level * 0.85),
        "dependency_failures": level,
        "test_failures": level,
    }


class BrainTests(unittest.TestCase):
    def setUp(self):
        self.samples = [
            ([features(level)[name] for name in FEATURE_NAMES], target)
            for level, target in ((0.05, 0.05), (0.15, 0.12), (0.35, 0.32),
                                  (0.55, 0.56), (0.75, 0.78), (0.95, 0.96))
        ]

    def test_training_is_deterministic_and_produces_bounded_score(self):
        first = train(self.samples, epochs=300, seed=19)
        second = train(self.samples, epochs=300, seed=19)
        self.assertEqual(first["weights_input_hidden"], second["weights_input_hidden"])
        self.assertEqual(first["weights_hidden_output"], second["weights_hidden_output"])
        score = predict(first, features(0.7))
        self.assertGreaterEqual(score, 0.0)
        self.assertLessEqual(score, 1.0)
        self.assertEqual(first["metadata"]["state"], "trained_experimental")

    def test_model_round_trip_and_no_overwrite_by_default(self):
        model = train(self.samples, epochs=40)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "model.json"
            save_model(model, path)
            self.assertEqual(load_model(path), model)
            with self.assertRaises(BrainDataError):
                save_model(model, path)
            save_model(model, path, force=True)

    def test_invalid_features_are_rejected(self):
        with self.assertRaises(BrainDataError):
            validate_features({"cpu_pressure": 2})
        with self.assertRaises(BrainDataError):
            validate_features({name: 0.1 for name in FEATURE_NAMES[:-1]})
        with self.assertRaises(BrainDataError):
            validate_features({**features(0.2), "unexpected": 0.0})

    def test_dataset_schema_and_sample_count_are_enforced(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "dataset.json"
            path.write_text(json.dumps({"schema": SCHEMA_DATASET, "samples": [
                {"features": features(0.1), "target": 0.1}
            ]}), encoding="utf-8")
            with self.assertRaises(BrainDataError):
                load_dataset(path)

    def test_cli_demo_does_not_need_or_write_a_model(self):
        self.assertEqual(main(["demo", "--epochs", "20"]), 0)

    def test_cli_status_is_available(self):
        self.assertEqual(main(["status"]), 0)

    def test_cli_analyze_outputs_explainable_json_without_model(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "features.json"
            path.write_text(json.dumps(features(0.8)), encoding="utf-8")
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                result = main(["analyze", "--features", str(path)])
            self.assertEqual(result, 0)
            document = json.loads(output.getvalue())
            self.assertEqual(document["schema"], "blumix.brain.analysis.v1")
            self.assertIsNone(document["neural"])
            self.assertFalse(document["action_taken"])

    def test_deterministic_reasoner_is_explainable_and_bounded(self):
        result = analyze_features(features(0.8))
        self.assertGreaterEqual(result["score"], 0.0)
        self.assertLessEqual(result["score"], 1.0)
        self.assertEqual(result["algorithm"], "BLUMIX-EXPLICIT-WEIGHTED-RULES-1")
        self.assertTrue(result["findings"])

    def test_untrained_model_is_not_mislabelled(self):
        model = new_model()
        self.assertEqual(model["metadata"]["state"], "untrained")
        self.assertGreaterEqual(predict(model, features(0.4)), 0.0)


if __name__ == "__main__":
    unittest.main()
