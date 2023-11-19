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

