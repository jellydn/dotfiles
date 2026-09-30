#!/usr/bin/env python3
"""Exercise Linux service setup without changing the host."""
from pathlib import Path
import os
import re
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
        self.home = self.base / "home"
        self.home.mkdir()
        self.calls = self.base / "calls"
        self.env = os.environ | {
            "PATH": f"{self.bin}:/usr/bin:/bin",
            "CALLS": str(self.calls),
            "HOME": str(self.home),
            "XDG_CONFIG_HOME": str(self.home / ".config"),
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
        self.assertIn("sudo systemctl enable --force greetd.service", calls)
        self.assertIn("systemctl is-enabled --quiet greetd.service", calls[-1])

    def test_missing_greetd_unit_preserves_etc(self):
        self.stub("systemctl", "exit 0")
        self.stub("sudo", 'echo "sudo $*" >> "$CALLS"')
        result = self.run_script("scripts/setup-greetd.sh", success=False)
        self.assertIn("sudo dnf install greetd tuigreet", result.stderr)
        self.assertFalse(self.calls.exists())

    def test_desktop_commands_have_safe_simulations(self):
        self.stub("dnf", 'echo "dnf $*" >> "$CALLS"')
        for desktop, expected in (
            ("niri", ("niri", "waybar", "systemd", "greetd", "fish")),
            ("i3", ("i3", "i3status", "polybar", "rofi")),
        ):
            with self.subTest(desktop=desktop):
                result = subprocess.run(
                    ["bash", str(ROOT / "install.sh"), desktop, "--simulate"],
                    cwd=ROOT,
                    env=self.env,
                    text=True,
                    capture_output=True,
                )
                self.assertEqual(
                    result.returncode, 0, result.stdout + result.stderr
                )
                for name in expected:
                    self.assertIn(name, result.stdout)
                self.assertIn(str(ROOT), result.stdout)
                self.assertFalse(self.calls.exists())
                self.assertEqual(list(self.home.iterdir()), [])

    def test_i3_config_has_unique_top_level_bindings(self):
        config = (ROOT / "linux" / ".config" / "i3" / "config").read_text()
        bindings = re.findall(r"^bindsym\s+(\S+)", config, re.MULTILINE)
        duplicates = sorted(
            binding for binding in set(bindings) if bindings.count(binding) > 1
        )
        self.assertEqual(duplicates, [])

    def test_i3_install_validates_the_linked_config(self):
        self.stub("dnf", 'echo "dnf $*" >> "$CALLS"')
        self.stub("sudo", 'echo "sudo $*" >> "$CALLS"')
        self.stub("i3", 'echo "i3 $*" >> "$CALLS"')

        result = subprocess.run(
            ["bash", str(ROOT / "install.sh"), "i3"],
            cwd=ROOT,
            env=self.env,
            text=True,
            capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        expected_config = self.home / ".config" / "i3" / "config"
        self.assertIn(f"i3 -C -c {expected_config}", self.calls.read_text())

    def test_niri_install_preserves_unrelated_systemd_units(self):
        user_units = self.home / ".config" / "systemd" / "user"
        user_units.mkdir(parents=True)
        unrelated = user_units / "keep-me.service"
        unrelated.write_text("[Service]\nExecStart=/bin/true\n")
        self.stub("dnf", 'echo "dnf $*" >> "$CALLS"')
        self.stub("niri", '[[ "$1" == "validate" ]]')
        self.stub("sudo", 'echo "sudo $*" >> "$CALLS"')
        self.stub(
            "systemctl",
            'echo "systemctl $*" >> "$CALLS"\n'
            'if [[ "$1" == "list-unit-files" ]]; then '
            'echo "greetd.service enabled"; fi',
        )

        result = subprocess.run(
            ["bash", str(ROOT / "install.sh"), "niri"],
            cwd=ROOT,
            env=self.env,
            text=True,
            capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(unrelated.is_file())
        for name in ("waybar.service", "wallpaper.service", "swayidle.service"):
            target = user_units / name
            self.assertTrue(target.is_file())
            self.assertFalse(target.is_symlink())
        for name in ("niri-copy.sh", "niri-paste.sh", "niri-power-menu.sh"):
            target = self.home / ".local" / "bin" / name
            self.assertTrue(target.is_symlink())
            self.assertTrue(target.resolve().is_file())
        wallpaper = self.home / ".local" / "share" / "dotfiles" / "Kanagawa.jpg"
        self.assertTrue(wallpaper.is_symlink())
        self.assertTrue(wallpaper.resolve().is_file())

    def test_niri_install_unfolds_stow_linked_systemd_directory(self):
        config = self.home / ".config"
        config.mkdir()
        systemd = config / "systemd"
        systemd.symlink_to(ROOT / "linux" / ".config" / "systemd")
        original = (ROOT / "linux" / ".config" / "systemd" / "user" / "waybar.service").read_text()
        self.stub("dnf", 'echo "dnf $*" >> "$CALLS"')
        self.stub("niri", '[[ "$1" == "validate" ]]')
        self.stub("sudo", 'echo "sudo $*" >> "$CALLS"')
        self.stub(
            "systemctl",
            'echo "systemctl $*" >> "$CALLS"\n'
            'if [[ "$1" == "list-unit-files" ]]; then '
            'echo "greetd.service enabled"; fi',
        )

        for _ in range(2):
            result = subprocess.run(
                ["bash", str(ROOT / "install.sh"), "niri"],
                cwd=ROOT,
                env=self.env,
                text=True,
                capture_output=True,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

        self.assertTrue(systemd.is_dir())
        self.assertFalse(systemd.is_symlink())
        self.assertEqual(
            (ROOT / "linux" / ".config" / "systemd" / "user" / "waybar.service").read_text(),
            original,
        )
        for name in ("waybar.service", "wallpaper.service", "swayidle.service"):
            target = systemd / "user" / name
            self.assertTrue(target.is_file())
            self.assertFalse(target.is_symlink())
        self.assertEqual(list((systemd / "user").glob("*_backup_*")), [])

    def test_niri_copy_and_paste_use_json_window_data(self):
        self.stub(
            "niri",
            '[[ "$*" == "msg --json windows" ]] || exit 2\n'
            'printf \'[%s]\\n\' "${NIRI_WINDOW}"',
        )
        self.stub("wtype", 'echo "$*" >> "$CALLS"')
        for script, key in (("niri-copy.sh", "c"), ("niri-paste.sh", "v")):
            for app_id, expected in (
                ("foot", f"-M ctrl -M shift -k {key}"),
                ("firefox", f"-M ctrl -k {key}"),
            ):
                with self.subTest(script=script, app_id=app_id):
                    self.calls.unlink(missing_ok=True)
                    env = self.env | {
                        "NIRI_WINDOW": (
                            '{"is_focused":true,"app_id":"' + app_id + '"}'
                        )
                    }
                    result = subprocess.run(
                        ["bash", str(ROOT / "linux" / ".local" / "bin" / script)],
                        env=env,
                        text=True,
                        capture_output=True,
                    )
                    self.assertEqual(
                        result.returncode, 0, result.stdout + result.stderr
                    )
                    self.assertEqual(self.calls.read_text().strip(), expected)


if __name__ == "__main__":
    unittest.main(verbosity=2)
