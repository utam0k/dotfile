"""Check that installing shared tools preserves existing user configuration."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
SOURCE = REPO / "mise/config.toml"


class MiseSetupTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix=".mise-test-", dir=REPO)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.config_dir = self.root / "config/mise"
        self.config_dir.mkdir(parents=True)
        self.target = self.config_dir / "config.toml"
        self.log = self.root / "calls"
        bindir = self.root / "bin"
        bindir.mkdir()
        fake = bindir / "mise"
        fake.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$MISE_TEST_LOG"\n')
        fake.chmod(0o755)
        self.env = dict(os.environ)
        for name in ("MISE_CONFIG_DIR", "MISE_DATA_DIR", "GH_DATA_DIR"):
            self.env.pop(name, None)
        self.env.update(
            PATH=f"{bindir}:/usr/bin:/bin",
            XDG_CONFIG_HOME=str(self.root / "config"),
            XDG_DATA_HOME=str(self.root / "data"),
            MISE_TEST_LOG=str(self.log),
        )
        self.extension = self.root / "data/gh/extensions/gh-worktree/gh-worktree"
        self.shim = self.root / "data/mise/shims/gh-worktree"

    def run_setup(self, check=True):
        return subprocess.run(
            ["sh", str(REPO / "install/mise.sh")],
            cwd=self.root,
            env=self.env,
            check=check,
            capture_output=True,
            text=True,
        )

    def test_fresh_install_and_repeated_run(self):
        self.run_setup()
        self.run_setup()
        self.assertEqual(self.target.readlink(), SOURCE)
        self.assertEqual(list(self.config_dir.glob("config.toml.backup.*")), [])
        self.assertEqual(
            self.log.read_text().splitlines(),
            [f"trust {SOURCE}", f"-C {REPO} install"] * 2,
        )
        self.assertEqual(self.extension.readlink(), self.shim)

    def test_existing_config_is_preserved_once(self):
        original = '[tools]\ncustom = "1.2.3"\n'
        self.target.write_text(original)
        self.run_setup()
        self.run_setup()
        backups = list(self.config_dir.glob("config.toml.backup.*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), original)
        self.assertEqual(self.target.readlink(), SOURCE)

    def test_dangling_symlink_is_preserved(self):
        previous = self.root / "missing-config"
        self.target.symlink_to(previous)
        self.run_setup()
        backup, = self.config_dir.glob("config.toml.backup.*")
        self.assertEqual(backup.readlink(), previous)
        self.assertEqual(self.target.readlink(), SOURCE)

    def test_mise_config_dir_takes_precedence(self):
        override = self.root / "other config"
        self.env["MISE_CONFIG_DIR"] = str(override)
        self.run_setup()
        self.assertEqual((override / "config.toml").readlink(), SOURCE)
        self.assertFalse(self.target.exists())

    def test_directory_is_not_replaced(self):
        self.target.mkdir()
        sentinel = self.target / "keep"
        sentinel.write_text("keep me")
        result = self.run_setup(check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(sentinel.read_text(), "keep me")
        self.assertFalse(self.log.exists())

    def test_gh_data_dirs_take_precedence(self):
        self.env["GH_DATA_DIR"] = str(self.root / "gh data")
        self.env["MISE_DATA_DIR"] = str(self.root / "mise data")
        self.run_setup()
        extension = self.root / "gh data/extensions/gh-worktree/gh-worktree"
        self.assertEqual(extension.readlink(), self.root / "mise data/shims/gh-worktree")
        self.assertFalse(self.extension.parent.exists())

    def test_other_gh_worktree_extension_is_not_replaced(self):
        self.extension.parent.mkdir(parents=True)
        self.extension.write_text("installed by hand")
        result = self.run_setup(check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("gh extension remove worktree", result.stderr)
        self.assertEqual(self.extension.read_text(), "installed by hand")
        self.assertFalse(self.log.exists())
        self.assertFalse(self.target.exists())


if __name__ == "__main__":
    unittest.main()
