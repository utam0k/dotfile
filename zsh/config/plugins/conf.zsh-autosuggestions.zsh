# https://github.com/tarruda/zsh-autosuggestions
source $ZPLUGINSDIR/zsh-autosuggestions/zsh-autosuggestions.zsh

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=7'

# Enable autosuggestions automatically.
# zle-line-init() {
#     zle autosuggest-start
# }
# zle -N zle-line-init

bindkey '^T' autosuggest-accept


