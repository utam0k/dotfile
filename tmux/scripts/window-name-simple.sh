#!/bin/bash
# tmux window name generator with simple Unicode icons

cmd="${1:-zsh}"
path="${2:-$PWD}"

# Shorten command name (show only basename without path)
cmd="${cmd##*/}"

# Get directory name
dir="${path##*/}"

# Get icon based on command (using simpler Unicode)
get_command_icon() {
    case "$1" in
        vim|nvim) echo "◈ " ;;
        zsh|bash|sh|fish) echo "▶ " ;;
        git) echo "⎇ " ;;
        node|npm|yarn|pnpm) echo "◆ " ;;
        python|python3|pip) echo "◉ " ;;
        docker) echo "▣ " ;;
        kubectl|k) echo "☸ " ;;
        make) echo "▪ " ;;
        ssh) echo "◐ " ;;
        claude|ai) echo "✦ " ;;
        *) echo "▸ " ;;
    esac
}

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

# Get appropriate icon
cmd_icon=$(get_command_icon "$cmd")

# If command is a shell, focus on directory and branch
if [[ "$cmd" =~ ^(bash|zsh|sh|fish)$ ]]; then
    if [[ -n "$git_branch" ]]; then
        echo "${cmd_icon}${dir}[⎇${git_branch}]"
    else
        echo "${cmd_icon}${dir}"
    fi
else
    # For non-shell commands, show command icon and name
    if [[ -n "$git_branch" && ${#git_branch} -le 8 ]]; then
        echo "${cmd_icon}${cmd}:${dir}"
    else
        echo "${cmd_icon}${cmd}:${dir}"
    fi
fi