#!/bin/bash
# Test script to debug git branch detection

path="${1:-$PWD}"

echo "Testing path: $path"
echo "---"

# Check if .git exists and what type
if [[ -e "$path/.git" ]]; then
    if [[ -f "$path/.git" ]]; then
        echo ".git is a file (likely a worktree)"
        echo "Contents: $(cat "$path/.git")"
        
        # Extract gitdir path
        gitdir=$(sed 's/gitdir: //' < "$path/.git")
        echo "Git dir: $gitdir"
        
        if [[ -f "$gitdir/HEAD" ]]; then
            echo "HEAD contents: $(cat "$gitdir/HEAD")"
        fi
    elif [[ -d "$path/.git" ]]; then
        echo ".git is a directory (regular repo)"
        if [[ -f "$path/.git/HEAD" ]]; then
            echo "HEAD contents: $(cat "$path/.git/HEAD")"
        fi
    fi
else
    echo ".git not found in $path"
fi

echo "---"

# Test the actual branch detection
get_git_branch() {
    local dir="$1"
    while [[ "$dir" != "/" ]]; do
        if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
            local branch

            branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null)
            if [[ -n "$branch" ]]; then
                echo "$branch"
                return
            fi

            branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
            if [[ -n "$branch" && "$branch" != "HEAD" ]]; then
                echo "$branch"
                return
            fi

            branch=$(git -C "$dir" name-rev --name-only --no-undefined HEAD 2>/dev/null)
            if [[ -n "$branch" && "$branch" != "undefined" ]]; then
                echo "$branch"
                return
            fi

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

branch=$(get_git_branch "$path")
echo "Detected branch: $branch"
