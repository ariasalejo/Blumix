#!/usr/bin/env python3
"""Pruebas de integración del servidor web local, sin dependencias externas."""
import importlib.util
import json
import threading
import unittest
from http.client import HTTPConnection
from pathlib import Path
from http.server import ThreadingHTTPServer

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("blumix_web", ROOT / "bin" / "blumix-web.py")
WEB = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(WEB)


class WebTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), WEB.Handler)
        cls.server.daemon_threads = True
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.port = cls.server.server_port

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join(timeout=2)

    def request(self, path, method="GET", host=None):
        conn = HTTPConnection("127.0.0.1", self.port, timeout=10)
        headers = {}
        if host:
            headers["Host"] = host
        conn.request(method, path, headers=headers)
        response = conn.getresponse()
        body = response.read()
        result = (response.status, dict(response.getheaders()), body)
        conn.close()
        return result

    def test_dashboard_and_security_headers(self):
        status, headers, body = self.request("/")
        self.assertEqual(status, 200)
        self.assertIn(b"BLUMIX Intelligence Center", body)
        self.assertEqual(headers.get("X-Content-Type-Options"), "nosniff")
        self.assertEqual(headers.get("X-Frame-Options"), "DENY")
        self.assertIn("127.0.0.1", str(WEB.ROOT))

    def test_manifest_and_service_worker(self):
        status, _, body = self.request("/manifest.webmanifest")
        self.assertEqual(status, 200)
        manifest = json.loads(body)
        self.assertEqual(manifest["name"], "BLUMIX Intelligence Center")
        self.assertEqual(manifest["display"], "standalone")
        status, _, sw = self.request("/sw.js")
        self.assertEqual(status, 200)
        self.assertIn(b"blumix-intelligence-shell-v1", sw)
        self.assertIn(b"/api/", sw)

    def test_api_schemas_are_real_cli_output(self):
        for route, schema in (
            ("/api/intelligence", "blumix.intelligence.v1"),
            ("/api/projects", "blumix.projects.v1"),
            ("/api/services", "blumix.services.v1"),
        ):
            with self.subTest(route=route):
                status, headers, body = self.request(route)
                self.assertEqual(status, 200, body.decode("utf-8", "replace"))
                self.assertIn("application/json", headers.get("Content-Type", ""))
                data = json.loads(body)
                self.assertEqual(data["schema"], schema)
                self.assertTrue(data["read_only"])
                self.assertNotIn("password", body.decode("utf-8").lower())

    def test_rejects_untrusted_host(self):
        status, _, body = self.request("/", host="attacker.example")
        self.assertEqual(status, 403)
        self.assertIn(b"Host no permitido", body)

    def test_only_get_is_supported(self):
        status, _, body = self.request("/", method="POST")
        self.assertEqual(status, 405)
        self.assertIn(b"Solo se permiten solicitudes GET", body)

    def test_unknown_route_is_json_404(self):
        status, headers, body = self.request("/api/run-shell")
        self.assertEqual(status, 404)
        self.assertIn("application/json", headers.get("Content-Type", ""))
        self.assertIn(b"Ruta no encontrada", body)


if __name__ == "__main__":
    unittest.main(verbosity=2)
