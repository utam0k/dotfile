# emacsキーバインドを使用
bindkey -e

setopt ignore_eof

# 補完
setopt COMPLETE_IN_WORD

# コピペ時PROMPTを消す
setopt TRANSIENT_RPROMPT

# BEEPを消す
setopt NO_BEEP

setopt auto_pushd

autoload -U colors; colors
autoload -U compinit; compinit

