#!/bin/bash
# tmux window name generator with color support

cmd="${1:-zsh}"
path="${2:-$PWD}"

# Shorten command name (show only basename without path)
cmd="${cmd##*/}"

# Get git branch (fast method by reading .git/HEAD directly)
get_git_branch() {
    local dir="$1"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.git/HEAD" ]]; then
            local branch
            branch=$(sed 's/ref: refs\/heads\///' < "$dir/.git/HEAD" 2>/dev/null)
            [[ -n "$branch" && "$branch" != *"HEAD"* ]] && echo "$branch" && return
        fi
        dir=$(dirname "$dir")
    done
}

# Get git branch if exists
git_branch=$(get_git_branch "$path")

# Format with colors for git branch
if [[ -n "$git_branch" ]]; then
    echo "${cmd} #[fg=#9ece6a]⎇ ${git_branch}#[default]"
else
    echo "${cmd}"
fi