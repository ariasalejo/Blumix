#!/usr/bin/env python3
"""Static regression checks for the offline BLUMIX Brain Atlas."""
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ATLAS = ROOT / "docs" / "visual-atlas" / "index.html"
LAUNCHER = ROOT / "scripts" / "launch-atlas-demo.sh"


class BrainAtlasTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.html = ATLAS.read_text(encoding="utf-8")

    def test_brain_view_is_reachable_from_navigation(self):
        self.assertIn('data-view="brain"', self.html)
        self.assertIn('id="view-brain"', self.html)
        self.assertIn("CEREBRO BLUMIX", self.html)

    def test_brain_view_accepts_snapshot_and_evidence_schemas(self):
        self.assertIn("blumix.snapshot.v1", self.html)
        self.assertIn("blumix.brain.evidence.v1", self.html)
        self.assertIn("validateBrainEvidence", self.html)
        self.assertIn("snapshotToBrainEvidence", self.html)

    def test_unknown_signals_are_not_coerced_to_zero(self):
        self.assertIn("dependency_failures:null,test_failures:null", self.html)
        self.assertIn("No se calculará puntuación neuronal", self.html)
        self.assertIn("DESCONOCIDO", self.html)

    def test_dynamic_evidence_uses_text_content(self):
        self.assertIn("label.textContent=metaName(name)", self.html)
        self.assertIn("detail.textContent='Origen: '", self.html)
        self.assertNotIn("innerHTML=e.", self.html)

    def test_demo_launcher_binds_to_loopback(self):
        script = LAUNCHER.read_text(encoding="utf-8")
        self.assertIn("--bind 127.0.0.1", script)
        self.assertIn("PORT < 1024 || PORT > 65535", script)
        self.assertNotIn("sudo ", script)


if __name__ == "__main__":
    unittest.main()
