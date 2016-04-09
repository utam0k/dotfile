# https://github.com/tarruda/zsh-autosuggestions
source $ZPLUGINSDIR/zsh-autosuggestions/zsh-autosuggestions.zsh

# Enable autosuggestions automatically.
zle-line-init() {
    zle autosuggest-start
}
zle -N zle-line-init

