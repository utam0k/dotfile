"""Check the zsh `review` command and bin/review-worktree.

gh (including `gh worktree`), peco and nvim are replaced by fakes; the zsh
function and the script are real. gh-worktree's own behaviour is tested in its
repository.
"""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
SOURCE = REPO / "zsh/zshrc.d/65-review.zsh"

# Mirrors gh-worktree: `cd` fails for a missing worktree, `pr --cd` creates it,
# and both print the path without a newline. `sync` reports to stdout.
FAKE_GH = """\
printf "%s\\n" "$*" >> "$REVIEW_TEST_LOG"
for number; do :; done
worktree="$PWD/.worktree/pr/pr-$number"
case "$1 $2" in
"pr list") printf "%s" "$REVIEW_TEST_PRS" ;;
"worktree cd")
    [ -d "$worktree" ] || { echo "worktree for PR #$number not found" >&2; exit 1; }
    printf "%s" "$worktree" ;;
"worktree pr") mkdir -p "$worktree" && printf "%s" "$worktree" ;;
"worktree sync")
    if [ -n "$REVIEW_TEST_SYNC_ERROR" ]; then
        echo "$REVIEW_TEST_SYNC_ERROR" >&2
        exit 1
    fi
    echo "Synced PR #$number to abc1234" ;;
esac
"""


class ReviewCommandTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix=".review-test-", dir=REPO)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        bindir = self.root / "bin"
        bindir.mkdir()
        self.fake(bindir / "gh", FAKE_GH)
        self.fake(bindir / "peco", 'echo peco >> "$REVIEW_TEST_LOG"\n'
                  'head -n "${PECO_PICK:-1}" | tail -n 1\n')
        self.fake(bindir / "nvim", 'printf "nvim %s %s\\n" "$PWD" "$*" >> "$REVIEW_TEST_LOG"\n')
        self.log = self.root / "calls"
        self.env = dict(os.environ)
        self.env.update(
            PATH=f"{bindir}:{os.environ['PATH']}",
            REVIEW_TEST_LOG=str(self.log),
            REVIEW_TEST_PRS="7\tTest PR\tpr7\tOPEN\n8\tOther\tpr8\tOPEN\n",
            REVIEW_TEST_SYNC_ERROR="",
        )
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.worktree = self.repo / ".worktree/pr/pr-7"

        # ~/.zshrc is a symlink to the built zshrc, so source the file through one.
        self.rc = self.root / "zshrc"
        self.rc.symlink_to(SOURCE)

    def fake(self, path, body):
        path.write_text("#!/bin/sh\n" + body)
        path.chmod(0o755)

    def review(self, *args, **env):
        script = f'source {self.rc}; review {" ".join(args)}; echo "status=$? pwd=$PWD"'
        return subprocess.run(
            ["zsh", "-fc", script],
            cwd=self.repo,
            env={**self.env, **env},
            check=False,
            capture_output=True,
            text=True,
        )

    def calls(self):
        return self.log.read_text().splitlines() if self.log.exists() else []

    def test_review_number_creates_the_worktree_and_opens_the_diff(self):
        result = self.review("7")
        self.assertIn(f"status=0 pwd={self.worktree}", result.stdout, result.stderr)
        self.assertEqual(
            self.calls(),
            ["worktree cd 7", "worktree pr --cd 7", f"nvim {self.worktree} +CodeDiff"],
        )

    def test_existing_worktree_is_moved_to_the_latest_head(self):
        self.worktree.mkdir(parents=True)
        result = self.review("7")
        self.assertIn(f"status=0 pwd={self.worktree}", result.stdout, result.stderr)
        self.assertEqual(
            self.calls(),
            [
                "worktree cd 7",
                "worktree pr --reuse --cd 7",
                "worktree sync 7",
                f"nvim {self.worktree} +CodeDiff",
            ],
        )

    def test_review_without_number_picks_an_open_pr_with_peco(self):
        result = self.review(PECO_PICK="2")
        worktree = self.repo / ".worktree/pr/pr-8"
        self.assertIn(f"status=0 pwd={worktree}", result.stdout, result.stderr)
        calls = self.calls()
        self.assertEqual(calls[:2], ["pr list", "peco"])
        self.assertEqual(calls[-1], f"nvim {worktree} +CodeDiff")

    def test_cancelled_pick_stays_put(self):
        result = self.review(PECO_PICK="0")
        self.assertIn(f"status=1 pwd={self.repo}", result.stdout, result.stderr)
        self.assertEqual(self.calls(), ["pr list", "peco"])

    def test_no_open_pull_requests_skips_peco(self):
        result = self.review(REVIEW_TEST_PRS="")
        self.assertIn(f"status=1 pwd={self.repo}", result.stdout)
        self.assertIn("no open pull requests", result.stderr)
        self.assertEqual(self.calls(), ["pr list"])

    def test_failure_keeps_the_shell_and_skips_nvim(self):
        self.worktree.mkdir(parents=True)
        error = "worktree has local changes; use --force to discard them"
        result = self.review("7", REVIEW_TEST_SYNC_ERROR=error)
        self.assertIn(f"status=1 pwd={self.repo}", result.stdout)
        self.assertIn(error, result.stderr)
        self.assertFalse(any(call.startswith("nvim ") for call in self.calls()))


if __name__ == "__main__":
    unittest.main()
