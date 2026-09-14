#!/usr/bin/env python3
"""Exercise Mac setup with fake host commands and disposable home directories."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="bootstrap test ")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.home = self.base / "home"
        self.home.mkdir()
        self.bin = self.base / "bin"
        self.bin.mkdir()
        self.log = self.base / "calls"
        self.env = {
            "HOME": str(self.home), "PATH": f"{self.bin}:/usr/bin:/bin",
            "CALLS": str(self.log), "TMPDIR": str(self.base),
        }
        self.stub("uname", 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac')
        for name in ("xcode-select", "curl", "git", "make", "mise"):
            self.stub(name, f'echo "{name} $*" >> "$CALLS"\nexit 99')

    def stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/bash\n" + body + "\n")
        path.chmod(0o755)

    def run_script(self, script="scripts/bootstrap-mac.sh", args=(), success=True):
        result = subprocess.run(
            ["/bin/bash", str(ROOT / script), *args], env=self.env,
            cwd=self.base, text=True, capture_output=True,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_all_preview_entrypoints_leave_home_and_commands_untouched(self):
        for script, args in (
            ("scripts/bootstrap-mac.sh", ["--dry-run"]),
            ("scripts/install-tools.sh", ["--dry-run"]),
            ("install.sh", ["all", "--simulate"]),
            ("install.sh", ["tools", "--simulate"]),
        ):
            with self.subTest(script=script, args=args):
                self.run_script(script, args)
                self.assertEqual(list(self.home.iterdir()), [])
                self.assertFalse(self.log.exists())

    def test_unrelated_config_and_dangling_link_stop_before_setup(self):
        dest = self.home / ".config/mise"
        dest.mkdir(parents=True)
        config = dest / "config.toml"
        config.write_text("# personal config\n")
        result = self.run_script(success=False)
        self.assertIn("Back it up", result.stdout)
        self.assertEqual(config.read_text(), "# personal config\n")
        self.assertFalse(self.log.exists())
        config.unlink()
        dest.rmdir()
        dest.symlink_to(self.base / "missing")
        self.run_script(success=False)
        self.assertTrue(dest.is_symlink())
        self.assertFalse(self.log.exists())

    def test_wrong_platform_and_bad_option_stop_before_setup(self):
        self.run_script(args=["--unknown"], success=False)
        for system, arch in (("Linux", "aarch64"), ("Darwin", "x86_64")):
            self.stub("uname", f'case "$1" in -s) echo {system};; -m) echo {arch};; esac')
            self.run_script(success=False)
        self.assertFalse(self.log.exists())

    def test_apply_uses_repo_config_and_home_not_callers_project(self):
        self.env["XDG_CONFIG_HOME"] = str(self.home / "custom config")
        self.stub("xcode-select", 'exit 0')
        self.stub("git", 'echo "git $*" >> "$CALLS"')
        self.stub("mise", 'printf "mise %s | %s | %s\\n" "$*" "$MISE_CONFIG_DIR" "$MISE_ENV" >> "$CALLS"')
        for _ in range(2):
            self.run_script(args=["--yes"])
        dest = self.home / "custom config/mise"
        self.assertEqual(dest.resolve(), ROOT / "common/.config/mise")
        calls = self.log.read_text()
        self.assertIn(f"-C {self.home} bootstrap --yes", calls)
        self.assertIn(f"| {dest} | macos", calls)
        self.assertLess(calls.index("submodule update"), calls.index("bootstrap --yes"))

    def test_missing_clt_requests_install_and_stops(self):
        self.stub("xcode-select", 'echo "$*" >> "$CALLS"\n[[ "$1" == --install ]]')
        self.run_script(success=False)
        self.assertEqual(self.log.read_text().splitlines(), ["-p", "--install"])
        self.assertEqual(list(self.home.iterdir()), [])

    def test_bad_mise_digest_never_installs_or_executes_download(self):
        (self.bin / "mise").unlink()
        self.stub("xcode-select", 'exit 0')
        self.stub("curl", 'printf "untrusted download" > "$4"')
        result = self.run_script(success=False)
        self.assertIn("FAILED", result.stdout + result.stderr)
        self.assertFalse((self.home / ".local/bin/mise").exists())
        self.assertFalse((self.home / ".config/mise").exists())
        self.assertEqual(list(self.base.glob("mise.*")), [])

    def test_interrupted_font_download_is_retried_and_cleanup_runs(self):
        self.stub("curl", 'printf partial > "$3"\nexit 23')
        self.run_script("common/.config/mise/macos-extras.sh", success=False)
        fonts = self.home / "Library/Fonts"
        self.assertEqual(list(fonts.iterdir()), [])
        self.stub("curl", 'printf complete > "$3"')
        self.run_script("common/.config/mise/macos-extras.sh", success=False)
        self.assertEqual((fonts / "sketchybar-app-font.ttf").read_text(), "complete")
        self.assertEqual(list(self.base.glob("SbarLua.*")), [])

    @unittest.skipUnless(os.environ.get("MISE_TEST_BIN"), "Set MISE_TEST_BIN for real mise integration")
    def test_real_mise_links_and_task_directory_with_custom_xdg(self):
        dest = self.home / "custom config/mise"
        dest.parent.mkdir()
        dest.symlink_to(ROOT / "common/.config/mise")
        env = self.env | {
            "XDG_CONFIG_HOME": str(dest.parent),
            "MISE_CONFIG_DIR": str(dest), "MISE_ENV": "macos",
            "MISE_TRUSTED_CONFIG_PATHS": f"{ROOT}:{self.home}",
            "MISE_YES": "1",
        }
        mise = os.environ["MISE_TEST_BIN"]
        for args in (["trust", str(dest / "config.toml")],
                     ["trust", str(dest / "config.macos.toml")],
                     ["bootstrap", "dotfiles", "apply"], ["tasks", "info", "bootstrap"]):
            result = subprocess.run([mise, "-C", str(self.home), *args], env=env,
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Directory: ~/custom config/mise", result.stdout)
        self.assertEqual((self.home / ".alacritty.toml").resolve(), ROOT / "macos/.alacritty.toml")
        self.assertEqual((self.home / ".config/alacritty/keys.toml").resolve(),
                         ROOT / "common/.config/alacritty/keys.toml")
        self.assertEqual((self.home / ".gitconfig").resolve(), ROOT / "common/.gitconfig")
        self.assertFalse((self.home / ".config/karabiner").exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
