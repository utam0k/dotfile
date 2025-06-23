#!/bin/bash

# Get session stack (MRU order)
session_stack=$(tmux list-windows -F '#{session_stack}' | head -1)
current_window=$(tmux display-message -p '#{window_index}')

# Get window information and format for fzf
window_list=""
IFS=',' read -ra windows <<< "$session_stack"

# Function to shorten path
shorten_path() {
    local path="$1"
    local max_len=60
    
    # Replace home directory with ~
    path="${path/#$HOME/~}"
    
    # If path is too long, shorten it
    if [ ${#path} -gt $max_len ]; then
        # Extract important parts
        local start=$(echo "$path" | cut -d'/' -f1-3)
        local end=$(echo "$path" | rev | cut -d'/' -f1-2 | rev)
        path="${start}/.../${end}"
    fi
    
    echo "$path"
}

for window_id in "${windows[@]}"; do
    # Skip current window to ensure consistent selection
    if [ "$window_id" = "$current_window" ]; then
        continue
    fi
    
    # Get detailed window information
    window_info=$(tmux list-windows -F "#{window_index}:#{window_name}:#{window_active}:#{pane_current_command}:#{pane_current_path}:#{window_panes}" | grep "^$window_id:")
    
    if [ -n "$window_info" ]; then
        IFS=':' read -r idx name is_active cmd path panes <<< "$window_info"
        
        # Shorten the path
        short_path=$(shorten_path "$path")
        
        # Format display with more information
        if [ "$panes" -gt 1 ]; then
            pane_info=" (${panes}p)"
        else
            pane_info=""
        fi
        
        display_line=$(printf "  [%s] %-12s%s :: %s" "$idx" "${name}${pane_info}" "" "$short_path")
        
        # Add to list with original window index for selection
        window_list="${window_list}${window_id}:${display_line}\n"
    fi
done

# Use fzf to select window with preview
result=$(echo -e "$window_list" | \
    fzf --reverse \
        --header "1-9: jump to window | Ctrl+J: next | Enter: select | Ctrl+C: cancel" \
        --preview 'tmux capture-pane -pt $(echo {} | cut -d: -f1)' \
        --preview-window right:50%:wrap \
        --expect=1,2,3,4,5,6,7,8,9 \
        --bind 'ctrl-j:down' \
        --bind 'ctrl-k:up' \
        --bind 'enter:accept' \
        --bind 'ctrl-c:abort' \
        --bind 'esc:abort' \
        --delimiter ':' \
        --with-nth 2.. \
        --no-sort \
        --cycle)

# Parse the result
key=$(echo "$result" | head -1)
selection=$(echo "$result" | tail -n +2)

# Handle number key press
if [[ "$key" =~ ^[1-9]$ ]]; then
    # Direct jump to window by number
    tmux select-window -t "$key"
elif [ -n "$selection" ]; then
    # Normal selection (Enter key)
    window_idx=$(echo "$selection" | cut -d: -f1)
    tmux select-window -t "$window_idx"
fi