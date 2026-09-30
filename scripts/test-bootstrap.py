#!/usr/bin/env python3
"""Test the remote bootstrap with disposable Git repositories and homes."""
from pathlib import Path
import os
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BOOTSTRAP = ROOT / "bootstrap.sh"


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-bootstrap-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.home = self.base / "home"
        self.home.mkdir()
        self.source = self.base / "source"
        self.remote = self.base / "remote.git"
        self.calls = self.base / "installer-calls"

        self.git("init", "--bare", str(self.remote), cwd=self.base)
        self.git("init", "-b", "master", str(self.source), cwd=self.base)
        self.git("config", "user.name", "Bootstrap Test", cwd=self.source)
        self.git("config", "user.email", "test@example.invalid", cwd=self.source)
        (self.source / "install.sh").write_text(
            '#!/usr/bin/env bash\nprintf "%s\\n" "$*" >> "$INSTALLER_CALLS"\n'
            '[[ "${FAIL_INSTALLER:-}" != 1 ]]\n'
        )
        self.commit("initial")
        self.initial_commit = self.git(
            "rev-parse", "HEAD", cwd=self.source
        ).stdout.strip()
        self.git("remote", "add", "origin", str(self.remote), cwd=self.source)
        self.git("push", "-u", "origin", "master", cwd=self.source)

        self.env = os.environ | {
            "HOME": str(self.home),
            "DOTFILES_REPO_URL": str(self.remote),
            "INSTALLER_CALLS": str(self.calls),
        }

    def git(self, *args, cwd):
        return subprocess.run(
            ["git", *args], cwd=cwd, check=True, text=True, capture_output=True
        )

    def commit(self, message):
        self.git("add", ".", cwd=self.source)
        self.git("commit", "-m", message, cwd=self.source)

    def run_bootstrap(self, *args, success=True, env=None):
        result = subprocess.run(
            ["bash", str(BOOTSTRAP), *args],
            env=self.env | (env or {}),
            cwd=self.base,
            text=True,
            capture_output=True,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_clone_defaults_to_all_and_repeated_run_fast_forwards(self):
        self.run_bootstrap()
        checkout = self.home / ".dotfiles"
        first_head = self.git("rev-parse", "HEAD", cwd=checkout).stdout.strip()
        self.assertEqual(self.calls.read_text().splitlines(), ["all"])

        (self.source / "version").write_text("two\n")
        self.commit("update")
        self.git("push", cwd=self.source)
        self.run_bootstrap("install", "--simulate")

        second_head = self.git("rev-parse", "HEAD", cwd=checkout).stdout.strip()
        self.assertNotEqual(first_head, second_head)
        self.assertEqual(
            self.calls.read_text().splitlines(), ["all", "install --simulate"]
        )

    def test_reviewed_commit_can_be_pinned(self):
        self.run_bootstrap(env={"DOTFILES_BRANCH": self.initial_commit})
        checkout = self.home / ".dotfiles"
        self.assertEqual(
            self.git("rev-parse", "HEAD", cwd=checkout).stdout.strip(),
            self.initial_commit,
        )
        self.run_bootstrap(env={"DOTFILES_BRANCH": self.initial_commit})

    def test_older_pin_and_local_ahead_checkout_are_rejected(self):
        self.run_bootstrap()
        checkout = self.home / ".dotfiles"

        (self.source / "version").write_text("two\n")
        self.commit("remote update")
        self.git("push", cwd=self.source)
        self.run_bootstrap()
        calls_before_rejections = self.calls.read_text()

        result = self.run_bootstrap(
            success=False, env={"DOTFILES_BRANCH": self.initial_commit}
        )
        self.assertIn("ahead of or has diverged", result.stderr)
        self.assertEqual(self.calls.read_text(), calls_before_rejections)

        self.git("config", "user.name", "Bootstrap Test", cwd=checkout)
        self.git("config", "user.email", "test@example.invalid", cwd=checkout)
        (checkout / "local-commit").write_text("keep\n")
        self.git("add", "local-commit", cwd=checkout)
        self.git("commit", "-m", "local commit", cwd=checkout)
        result = self.run_bootstrap(success=False)
        self.assertIn("ahead of or has diverged", result.stderr)
        self.assertEqual(self.calls.read_text(), calls_before_rejections)

    def test_unrelated_destination_is_not_changed(self):
        checkout = self.home / ".dotfiles"
        checkout.mkdir()
        marker = checkout / "keep"
        marker.write_text("safe\n")
        result = self.run_bootstrap(success=False)
        self.assertIn("not a Git checkout", result.stderr)
        self.assertEqual(marker.read_text(), "safe\n")

    def test_dirty_checkout_and_wrong_origin_are_rejected(self):
        self.run_bootstrap()
        checkout = self.home / ".dotfiles"
        self.git("config", "status.showUntrackedFiles", "no", cwd=checkout)
        (checkout / "local-change").write_text("keep\n")
        result = self.run_bootstrap(success=False)
        self.assertIn("local changes", result.stderr)
        (checkout / "local-change").unlink()

        self.git("remote", "set-url", "origin", str(self.base / "other.git"), cwd=checkout)
        result = self.run_bootstrap(success=False)
        self.assertIn("Refusing to update", result.stderr)

    def test_installer_failure_is_returned_without_removing_checkout(self):
        result = self.run_bootstrap(success=False, env={"FAIL_INSTALLER": "1"})
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue((self.home / ".dotfiles/.git").is_dir())


if __name__ == "__main__":
    unittest.main(verbosity=2)
