# Review a GitHub pull request: check it out into its own worktree with
# gh-worktree, cd there and open the PR's diff in Neovim. Without a number,
# pick an open PR with peco. Shared with Neovim's :Review (bin/review-worktree).

# Resolved from this file, which is zsh/zshrc.d/*.zsh or zsh/build/zshrc.
typeset -g REVIEW_WORKTREE=${${(%):-%x}:A:h:h:h}/bin/review-worktree

function review() {
    local number=$1
    if [[ -z $number ]]; then
        local prs
        prs=$(gh pr list) || return
        if [[ -z $prs ]]; then
            echo "review: no open pull requests" >&2
            return 1
        fi
        number=$(print -r -- "$prs" | peco | awk '{print $1}')
        [[ -n $number ]] || return 1
    fi

    local worktree
    worktree=$("$REVIEW_WORKTREE" "$number") || return
    # In review mode the worktree's local changes are the PR's diff.
    cd "$worktree" && nvim +CodeDiff
}
