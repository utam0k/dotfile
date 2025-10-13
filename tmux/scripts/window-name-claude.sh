#!/bin/bash
# tmux window name generator with Claude process detection using ccstatus
# Integrates with ccstatus command for accurate status detection

# Debug logging (uncomment to enable)
# DEBUG_LOG="/tmp/tmux-claude-ccstatus.log"
# echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script called with: $*" >> "$DEBUG_LOG"

cmd="${1:-zsh}"
path="${2:-$PWD}"
is_zoomed="${3:-0}"
pane_id="${4:-}"

# Get session and window info from pane_id
if [[ -n "$pane_id" ]]; then
    window_info=$(tmux list-panes -a -F '#{pane_id} #{session_name}:#{window_index}' 2>/dev/null | grep "^$pane_id" | awk '{print $2}')
    if [[ -n "$window_info" ]]; then
        session_name=$(echo "$window_info" | cut -d: -f1)
        window_index=$(echo "$window_info" | cut -d: -f2)
    fi
fi

# Debug output (uncomment to enable)
# echo "[$(date '+%Y-%m-%d %H:%M:%S')] DEBUG: pane_id=$pane_id, session=$session_name, window=$window_index" >> "$DEBUG_LOG"

# Shorten command name (show only basename without path)
cmd="${cmd##*/}"

# Get git branch (supports both regular repos and worktrees)
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

# Check Claude status using ccstatus command
check_claude_in_window() {
    local session="$1"
    local window="$2"
    
    # echo "[$(date '+%Y-%m-%d %H:%M:%S')] check_claude_in_window called: session=$session, window=$window" >> "$DEBUG_LOG"
    
    if [[ -z "$session" || -z "$window" ]]; then
        return 1
    fi
    
    # Get all panes in specified window
    local panes
    panes=$(tmux list-panes -t "${session}:${window}" -F '#{pane_id} #{pane_current_command}' 2>/dev/null)
    
    if [[ -z "$panes" ]]; then
        # echo "[$(date '+%Y-%m-%d %H:%M:%S')] No panes found in window" >> "$DEBUG_LOG"
        return 1
    fi
    
    # echo "[$(date '+%Y-%m-%d %H:%M:%S')] Panes found: $panes" >> "$DEBUG_LOG"
    
    # Check each pane for Claude and get status
    local final_state="none"
    local has_waiting=false
    local has_running=false
    local has_completed=false
    
    while IFS=' ' read -r pane_id pane_cmd; do
        if [[ "$pane_cmd" == "claude" ]] && [[ -n "$pane_id" ]]; then
            # echo "[$(date '+%Y-%m-%d %H:%M:%S')] Found Claude pane: $pane_id" >> "$DEBUG_LOG"
            # Get Claude status for this specific pane using ccstatus JSON output
            local state
            state=$(/home/utam0k/.local/bin/ccstatus tmux "$pane_id" -o json 2>/dev/null | jq -r '.state' 2>/dev/null)
            # echo "[$(date '+%Y-%m-%d %H:%M:%S')] ccstatus state for $pane_id: $state" >> "$DEBUG_LOG"
            
            if [[ -n "$state" ]]; then
                # Map states to status flags
                case "$state" in
                    "waiting")
                        has_waiting=true
                        ;;
                    "working")
                        has_running=true
                        ;;
                    "completed")
                        has_completed=true
                        ;;
                esac
            fi
        fi
    done <<< "$panes"
    
    # Determine final status based on priority (running > waiting > completed)
    if [[ "$has_running" == true ]]; then
        final_state="running"
    elif [[ "$has_waiting" == true ]]; then
        final_state="waiting"
    elif [[ "$has_completed" == true ]]; then
        final_state="completed"
    else
        final_state="none"
    fi
    
    echo "$final_state"
}

# Build basic output first
output="${cmd}"

# Get git branch if exists
git_branch=$(get_git_branch "$path")
if [[ -n "$git_branch" ]]; then
    output="${output} ⎇ ${git_branch}"
fi

# Add zoom indicator if pane is zoomed
if [[ "$is_zoomed" == "1" ]]; then
    output="${output} 🔍"
fi

# Check Claude status if session and window are provided
if [[ -n "$session_name" && -n "$window_index" ]]; then
    claude_status=$(check_claude_in_window "$session_name" "$window_index")
    
    # Add Claude indicator based on window-wide status
    case "$claude_status" in
        "waiting")
            output="⏸ ${output}"
            ;;
        "running")
            output="► ${output}"
            ;;
        "completed")
            output="✓ ${output}"
            ;;
    esac
else
    # Fallback: just check if current command is claude
    if [[ "$cmd" == "claude" ]]; then
        output="⏸ ${output}"
    fi
fi

# echo "[$(date '+%Y-%m-%d %H:%M:%S')] Final output: $output" >> "$DEBUG_LOG"
echo "${output}"
