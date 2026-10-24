"""Check the zsh `review` command against real git repositories.

gh, peco and nvim are replaced by fakes; git and bin/review-worktree are real.
The worktree rules themselves are covered through Neovim in nvim/tests/review.lua.
"""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
SOURCE = REPO / "zsh/zshrc.d/65-review.zsh"


class ReviewCommandTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix=".review-test-", dir=REPO)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        gitconfig = self.root / "gitconfig"
        gitconfig.write_text("[user]\n\tname = Review Test\n\temail = review@example.com\n")
        bindir = self.root / "bin"
        bindir.mkdir()
        self.fake(bindir / "gh", 'printf "%s\\n" "$*" >> "$REVIEW_TEST_LOG"\n'
                  'case "$1 $2" in\n'
                  '"pr view") printf "main\\tTest PR\\n" ;;\n'
                  '"pr list") printf "7\\tTest PR\\tpr7\\tOPEN\\n8\\tOther\\tpr8\\tOPEN\\n" ;;\n'
                  "esac\n")
        self.fake(bindir / "peco", 'tee -a "$REVIEW_TEST_LOG" | head -n "${PECO_PICK:-1}" | tail -n 1\n')
        self.fake(bindir / "nvim", 'printf "nvim %s %s\\n" "$PWD" "$*" >> "$REVIEW_TEST_LOG"\n')
        self.log = self.root / "calls"
        self.env = dict(os.environ)
        self.env.update(
            PATH=f"{bindir}:{os.environ['PATH']}",
            GIT_CONFIG_GLOBAL=str(gitconfig),
            GIT_CONFIG_NOSYSTEM="1",
            REVIEW_TEST_LOG=str(self.log),
        )

        remote = self.root / "remote.git"
        seed = self.root / "seed"
        self.clone = self.root / "clone"
        self.git(self.root, "init", "--quiet", "--bare", "--initial-branch=main", str(remote))
        self.git(self.root, "init", "--quiet", "--initial-branch=main", str(seed))
        (seed / "file.txt").write_text("base\n")
        self.git(seed, "add", ".")
        self.git(seed, "commit", "--quiet", "-m", "base")
        self.git(seed, "push", "--quiet", str(remote), "main")
        (seed / "file.txt").write_text("pr\n")
        self.git(seed, "commit", "--quiet", "-am", "pr")
        self.git(seed, "push", "--quiet", str(remote), "HEAD:refs/pull/7/head")
        self.pr_head = self.git(seed, "rev-parse", "HEAD")
        self.git(self.root, "clone", "--quiet", str(remote), str(self.clone))
        url = "https://github.com/test/repo.git"
        self.git(self.clone, "config", f"url.{remote}.insteadOf", url)
        self.git(self.clone, "remote", "set-url", "origin", url)
        (self.clone / ".git/info/exclude").write_text(".worktree/\n")
        self.worktree = self.clone / ".worktree/pr/pr-7"

        # ~/.zshrc is a symlink to the built zshrc, so source the file through one.
        self.rc = self.root / "zshrc"
        self.rc.symlink_to(SOURCE)

    def fake(self, path, body):
        path.write_text("#!/bin/sh\n" + body)
        path.chmod(0o755)

    def git(self, cwd, *args):
        result = subprocess.run(
            ["git", *args], cwd=cwd, env=self.env, check=True, capture_output=True, text=True
        )
        return result.stdout.strip()

    def review(self, *args, **env):
        script = f'source {self.rc}; review {" ".join(args)}; echo "status=$? pwd=$PWD"'
        return subprocess.run(
            ["zsh", "-fc", script],
            cwd=self.clone,
            env={**self.env, **env},
            check=False,
            capture_output=True,
            text=True,
        )

    def calls(self):
        return self.log.read_text().splitlines() if self.log.exists() else []

    def test_review_number_cds_into_the_worktree_and_opens_the_diff(self):
        result = self.review("7")
        self.assertIn(f"status=0 pwd={self.worktree}", result.stdout, result.stderr)
        self.assertEqual(self.git(self.worktree, "rev-parse", "HEAD"), self.pr_head)
        self.assertEqual(self.calls()[-1], f"nvim {self.worktree} +CodeDiff origin/main...")

    def test_review_without_number_picks_an_open_pr_with_peco(self):
        result = self.review(PECO_PICK="1")
        self.assertIn(f"status=0 pwd={self.worktree}", result.stdout, result.stderr)
        calls = self.calls()
        self.assertEqual(calls[0], "pr list --repo github.com/test/repo")
        self.assertIn("8\tOther\tpr8\tOPEN", calls, "peco did not receive the PR list")
        self.assertEqual(calls[-1], f"nvim {self.worktree} +CodeDiff origin/main...")

    def test_cancelled_pick_stays_put(self):
        result = self.review(PECO_PICK="0")
        self.assertIn(f"status=1 pwd={self.clone}", result.stdout, result.stderr)
        self.assertFalse(any(call.startswith("nvim ") for call in self.calls()))

    def test_failure_keeps_the_shell_and_skips_nvim(self):
        self.review("7")
        (self.worktree / "file.txt").write_text("my notes\n")
        self.log.unlink()
        result = self.review("7")
        self.assertIn(f"status=1 pwd={self.clone}", result.stdout)
        self.assertIn("has uncommitted changes", result.stderr)
        self.assertFalse(any(call.startswith("nvim ") for call in self.calls()))
        self.assertEqual((self.worktree / "file.txt").read_text(), "my notes\n")


if __name__ == "__main__":
    unittest.main()
