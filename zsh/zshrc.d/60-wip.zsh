# Save the current work state without GPG signature and optionally switch to a PR for review
function wip() {
    # Get the current branch name
    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Check for uncommitted changes and create a WIP commit without GPG signature
    if ! git diff --quiet || ! git diff --staged --quiet; then
        git add .
        git commit --no-gpg-sign -m "WIP-$current_branch: Save uncommitted changes before switching to PR review"
        git notes add -m "Auto-saved WIP commit"
    fi

    # Ask the user if they want to switch to a PR
    echo "Do you want to switch to a PR now? [Y/n]: "
    read switch_to_pr

    if [[ $switch_to_pr =~ ^[Yy]([eE][sS]|[yY])?$ ]]; then
        # Use GitHub CLI to fetch PR list and select with peco
        local pr_number=$(gh pr list | peco | awk '{print $1}')
        if [[ ! -z $pr_number ]]; then
            # git fetch origin pull/$pr_number/head:pr-$pr_number
            # git checkout pr-$pr_number
            gh pr checkout $pr_number
        else
            echo "No PR selected, staying on current branch."
        fi
    else
        echo "Not switching to a PR. Continue your work."
    fi
}

# Restore the original work state
function rwip() {
    # Check the last commit message
    local last_commit_msg=$(git log -1 --pretty=%B)

    # If the last commit is a WIP commit, show the note and offer to reset
    if [[ $last_commit_msg == WIP-* ]]; then
        echo "WIP notes:"
        git notes show

        # Ask the user to confirm reset
        read "?Do you want to reset the WIP commit? [Y/n]: " response
        if [[ $response =~ ^[Yy]([eE][sS]|[yY])?$ ]]; then
            git reset HEAD~1 --soft
            git restore --staged .
        fi
    fi
}

# Check for WIP commit on the current branch
check_wip_commit() {
    # Get the last commit message
    local last_commit_msg=$(git log -1 --pretty=%B)

    # If the last commit is a WIP commit, display a warning
    if [[ $last_commit_msg == WIP-* ]]; then
        echo "Warning: You have a WIP commit on this branch: $last_commit_msg"
    fi
}

