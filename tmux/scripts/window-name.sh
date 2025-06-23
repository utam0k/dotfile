#!/bin/bash
# Simple tmux window name generator

cmd="${1:-zsh}"
path="${2:-$PWD}"

# Shorten command name (show only basename without path)
cmd="${cmd##*/}"

# Get git branch (supports both regular repos and worktrees)
get_git_branch() {
    local dir="$1"
    while [[ "$dir" != "/" ]]; do
        if [[ -e "$dir/.git" ]]; then
            local head_file=""
            
            # Handle both regular repos and worktrees
            if [[ -f "$dir/.git" ]]; then
                # It's a worktree - .git is a file pointing to the real git dir
                local gitdir
                gitdir=$(sed 's/gitdir: //' < "$dir/.git")
                head_file="$gitdir/HEAD"
            elif [[ -d "$dir/.git" ]]; then
                # Regular repo - .git is a directory
                head_file="$dir/.git/HEAD"
            fi
            
            if [[ -n "$head_file" && -f "$head_file" ]]; then
                local branch
                branch=$(sed 's/ref: refs\/heads\///' < "$head_file" 2>/dev/null)
                if [[ -n "$branch" && "$branch" != *"HEAD"* ]]; then
                    echo "$branch"
                    return
                fi
            fi
        fi
        dir=$(dirname "$dir")
    done
}

# Get git branch if exists
git_branch=$(get_git_branch "$path")

# Check if pane is zoomed (not used in this version)
# is_zoomed="${3:-0}"

# Simple format: command + branch (if exists)
if [[ -n "$git_branch" ]]; then
    echo "${cmd} ⎇ ${git_branch}"
else
    echo "${cmd}"
fi