# Review a GitHub pull request: check it out into its own worktree, cd there and
# open the merge-base diff in Neovim. Without a number, pick an open PR with peco.
# The worktree handling is shared with Neovim's :Review (bin/review-worktree).

# Resolved from this file, which is zsh/zshrc.d/*.zsh or zsh/build/zshrc.
typeset -g REVIEW_WORKTREE=${${(%):-%x}:A:h:h:h}/bin/review-worktree

function review() {
    local number=$1
    if [[ -z $number ]]; then
        local repo
        repo=$("$REVIEW_WORKTREE" --repo) || return
        number=$(gh pr list --repo "$repo" | peco | awk '{print $1}')
        [[ -n $number ]] || return 1
    fi

    local -a worktree
    worktree=("${(@f)$("$REVIEW_WORKTREE" "$number")}") || return
    cd "$worktree[1]" && nvim +"CodeDiff $worktree[2]..."
}
