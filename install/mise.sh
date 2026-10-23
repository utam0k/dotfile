#!/bin/sh
set -eu

dotfiles_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)
source_config="$dotfiles_dir/mise/config.toml"
config_dir=${MISE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/mise}
target_config="$config_dir/config.toml"

if command -v mise >/dev/null 2>&1; then
    mise_bin=$(command -v mise)
elif [ -x "$HOME/.local/bin/mise" ]; then
    mise_bin="$HOME/.local/bin/mise"
else
    echo "Install mise first: https://mise.jdx.dev/getting-started.html" >&2
    exit 1
fi

if [ -d "$target_config" ]; then
    echo "Expected a file at $target_config, found a directory." >&2
    exit 1
fi

"$mise_bin" trust "$source_config"
mkdir -p "$config_dir"
if [ ! -L "$target_config" ] || [ "$(readlink "$target_config")" != "$source_config" ]; then
    if [ -e "$target_config" ] || [ -L "$target_config" ]; then
        backup=$(mktemp "$target_config.backup.XXXXXX")
        mv "$target_config" "$backup"
        printf 'Previous mise config saved to %s\n' "$backup"
    fi
    ln -s "$source_config" "$target_config"
fi

"$mise_bin" -C "$dotfiles_dir" install
printf 'mise tools are ready. Restart your shell to activate them.\n'
