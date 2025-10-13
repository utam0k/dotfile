#!/bin/bash
# tmux window name generator with zoom indicator

cmd="${1:-zsh}"
path="${2:-$PWD}"
is_zoomed="${3:-0}"

# Shorten command name (show only basename without path)
cmd="${cmd##*/}"

# Get git branch (supports both regular repos and worktrees)
get_git_branch() {
    local dir="$1"
    while [[ "$dir" != "/" ]]; do
        if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
            local branch

            # Prefer symbolic ref to avoid transient detached HEAD states.
            branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null)
            if [[ -n "$branch" ]]; then
                echo "$branch"
                return
            fi

            # Fallback to abbreviated ref when symbolic-ref is not available.
            branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
            if [[ -n "$branch" && "$branch" != "HEAD" ]]; then
                echo "$branch"
                return
            fi

            # Use name-rev to surface the closest ref before giving up.
            branch=$(git -C "$dir" name-rev --name-only --no-undefined HEAD 2>/dev/null)
            if [[ -n "$branch" && "$branch" != "undefined" ]]; then
                echo "$branch"
                return
            fi

            # As a last resort, indicate detached state with the short commit.
            local short_hash
            short_hash=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
            if [[ -n "$short_hash" ]]; then
                echo "detached@${short_hash}"
                return
            fi
        fi
        dir=$(dirname "$dir")
    done
}

# Get git branch if exists
git_branch=$(get_git_branch "$path")

# Build output with zoom indicator
output="${cmd}"
if [[ -n "$git_branch" ]]; then
    output="${output} ⎇ ${git_branch}"
fi

# Add zoom indicator if pane is zoomed
if [[ "$is_zoomed" == "1" ]]; then
    output="${output} 🔍"
fi

echo "${output}"
