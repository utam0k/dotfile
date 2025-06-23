#!/bin/bash
# Format window name with dynamic width and minimum padding

window_name="$1"
client_width="${2:-100}"
window_count="${3:-1}"

# Get optimal width
width=$(~/.tmux/scripts/get-window-width.sh "$client_width" "$window_count")

# Set minimum display width for visual balance
# Account for icon width (typically 2-3 characters including space)
min_display_width=15

# Use the larger of calculated width or minimum width
if [[ $width -lt $min_display_width ]]; then
    display_width=$min_display_width
else
    display_width=$width
fi

# Format the output
if [[ ${#window_name} -gt $display_width ]]; then
    # Truncate long names
    truncate_at=$((display_width - 3))
    echo "${window_name:0:$truncate_at}..."
elif [[ ${#window_name} -lt $min_display_width && $width -ge $min_display_width ]]; then
    # Pad short names to minimum width when there's enough space
    printf "%-${min_display_width}s" "$window_name"
else
    # Natural length for everything else
    echo "$window_name"
fi