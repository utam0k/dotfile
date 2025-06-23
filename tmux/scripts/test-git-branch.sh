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
        if [[ -e "$dir/.git" ]]; then
            local head_file=""
            
            # Handle both regular repos and worktrees
            if [[ -f "$dir/.git" ]]; then
                # It's a worktree
                local gitdir
                gitdir=$(sed 's/gitdir: //' < "$dir/.git")
                head_file="$gitdir/HEAD"
            elif [[ -d "$dir/.git" ]]; then
                # Regular repo
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

branch=$(get_git_branch "$path")
echo "Detected branch: $branch"