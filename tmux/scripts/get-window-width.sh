#!/bin/bash
# Dynamic max width calculator for tmux window names

client_width="${1:-100}"
window_count="${2:-1}"

# Avoid division by zero
[[ $window_count -eq 0 ]] && window_count=1

# Calculate available width per window
# Reserve space for: status-right (~30 chars), window numbers (2-3 chars each), separators
status_right_reserve=35
per_window_overhead=4  # "1:" prefix + separator
total_overhead=$((status_right_reserve + (window_count * per_window_overhead)))

# Calculate available width
available_width=$((client_width - total_overhead))
per_window_width=$((available_width / window_count))

# Apply constraints
min_width=10
max_width=50

if [[ $per_window_width -lt $min_width ]]; then
    per_window_width=$min_width
elif [[ $per_window_width -gt $max_width ]]; then
    per_window_width=$max_width
fi

echo "$per_window_width"