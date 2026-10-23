# dotfile

- nvim
- zsh
- tmux
- Xmodmap
- tmux
- fish(oh-my-fish)

## Tool versions

Editor, shell, and development CLI versions are pinned in
[`mise/config.toml`](mise/config.toml). This includes Neovim, Tree-sitter,
Lua Language Server, Node.js, fzf, ripgrep, fd, delta, peco, ghq, GitHub CLI,
lazygit, jq, tmux, kubectl, Go, golangci-lint, Terraform, and uv.

Install [mise](https://mise.jdx.dev/getting-started.html), then run from this
checkout:

```sh
make mise
```

This links the shared config to `~/.config/mise/config.toml` and installs its
tools. An existing config is moved to `config.toml.backup.XXXXXX` in the same
directory; running the command again keeps the existing link and backup.
`XDG_CONFIG_HOME` and `MISE_CONFIG_DIR` are respected. Personal overrides belong
in `~/.config/mise/config.local.toml`.

The global link makes the tools available outside this checkout, including
when Neovim starts in another project. Project-specific mise configs can still
override these defaults. The previous `nvim/mise.toml` has been consolidated
into the shared config.

The Bash, Zsh, and Fish configs activate mise. Rebuild Zsh with `make zshrc`
after changing its snippets, then restart the shell. To activate mise in an
existing Zsh session immediately:

```sh
eval "$(mise activate zsh)"
```

To update a tool to the latest release and record its exact version, run from
this checkout:

```sh
mise use --path "$PWD/mise/config.toml" --pin fzf@latest
git diff -- mise/config.toml
```

Use the same command with another tool name, or edit a version in the config
and run `make mise`. Commit the version changes to reproduce them on another
machine. Neovim plugins remain pinned in `nvim/lazy-lock.json`; other language
servers, formatters, and debuggers use the existing Mason configuration.
