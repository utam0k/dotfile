zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

has() {
	type "$1" > /dev/null 2>&1
}

HISTFILE=~/.zsh_history
HISTSIZE=100000000
SAVEHIST=${HISTSIZE}

setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end

PATH_LOADER="$HOME/.dotfiles/path_loader.zsh"
if [ -r "$PATH_LOADER" ]; then
	source "$PATH_LOADER"
fi

ZSH_COMPLETIONS="$HOME/.zsh/completions/zsh-completions/"
if [ -d $ZSH_COMPLETIONS ]; then
	fpath=("$ZSH_COMPLETIONS/src" $fpath)
fi

ZSH_AUTOSUGGESTIONS_PATH="$HOME/.zsh/plugins/zsh-autosuggestions/"
if [ -d "$ZSH_AUTOSUGGESTIONS_PATH" ]; then
	source "$ZSH_AUTOSUGGESTIONS_PATH/zsh-autosuggestions.zsh"
fi

ZSH_SYNTAX_HIGHLIGHTING_PATH="$HOME/.zsh/plugins/zsh-syntax-highlighting/"
if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_PATH" ]; then
	source "$ZSH_SYNTAX_HIGHLIGHTING_PATH/zsh-syntax-highlighting.zsh"
fi


for f in $(find "$HOME/.zsh/userautoload" -type f -name "*.zsh"); do source "$f"; done

alias vi='nvim'
export EDITOR='nvim'

if [ -r ~/.zshrc.local ]; then
  . ~/.zshrc.local
fi
