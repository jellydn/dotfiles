#!/usr/bin/env python3
"""Exercise Linux service setup without changing the host."""
from pathlib import Path
import os
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class LinuxSetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="linux-setup-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.bin = self.base / "bin"
        self.bin.mkdir()
        self.calls = self.base / "calls"
        self.env = os.environ | {
            "PATH": f"{self.bin}:/usr/bin:/bin",
            "CALLS": str(self.calls),
        }

    def stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/bash\n" + body + "\n")
        path.chmod(0o755)

    def run_script(self, path, success=True):
        result = subprocess.run(
            ["bash", str(ROOT / path)],
            cwd=self.base,
            env=self.env,
            text=True,
            capture_output=True,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_niri_services_attach_to_installed_niri_unit(self):
        self.stub(
            "systemctl",
            'echo "$*" >> "$CALLS"\n'
            'if [[ "$*" == "--user cat niri.service" ]]; then exit 0; fi',
        )
        self.run_script("linux/setup-niri-systemd.sh")
        calls = self.calls.read_text()
        self.assertIn("--user add-wants niri.service waybar.service", calls)
        self.assertIn("--user add-wants niri.service wallpaper.service", calls)
        self.assertIn("--user add-wants niri.service swayidle.service", calls)

    def test_missing_niri_unit_stops_before_adding_dependencies(self):
        self.stub(
            "systemctl",
            'echo "$*" >> "$CALLS"\n'
            'if [[ "$*" == "--user cat niri.service" ]]; then exit 1; fi',
        )
        result = self.run_script("linux/setup-niri-systemd.sh", success=False)
        self.assertIn("sudo dnf install niri", result.stderr)
        self.assertNotIn("add-wants", self.calls.read_text())

    def test_greetd_creates_directory_before_installing_config(self):
        self.stub(
            "systemctl",
            'if [[ "$1" == "list-unit-files" ]]; then echo "greetd.service enabled"; fi\n'
            'echo "systemctl $*" >> "$CALLS"',
        )
        self.stub("sudo", 'echo "sudo $*" >> "$CALLS"')
        self.run_script("scripts/setup-greetd.sh")
        calls = self.calls.read_text().splitlines()
        directory = calls.index("sudo install -d -m 0755 /etc/greetd")
        config = next(
            i for i, call in enumerate(calls) if "install -m 0644" in call
        )
        self.assertLess(directory, config)
        self.assertIn("systemctl enable greetd.service", calls[-1])

    def test_missing_greetd_unit_preserves_etc(self):
        self.stub("systemctl", "exit 0")
        self.stub("sudo", 'echo "sudo $*" >> "$CALLS"')
        result = self.run_script("scripts/setup-greetd.sh", success=False)
        self.assertIn("sudo dnf install greetd tuigreet", result.stderr)
        self.assertFalse(self.calls.exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
