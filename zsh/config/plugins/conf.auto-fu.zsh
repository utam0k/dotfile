# git clone https://github.com/hchbaw/auto-fu.zsh
# if use zsh-syntax-highlight, you clone the following branch
# git clone -b pu https://github.com/hchbaw/auto-fu.zsh

source $ZPLUGINSDIR/auto-fu/auto-fu.zsh

#-azfu-を表示しない
zstyle ':auto-fu:var' postdisplay $''
# zstyle ':auto-fu:var' track-keymap-skip opp
zstyle ':auto-fu:highlight' input bold
zstyle ':auto-fu:highlight' completion fg=black,bold
zstyle ':auto-fu:highlight' completion/one fg=white,bold,underline

zle-line-init () {
    auto-fu-init
}
zle -N zle-line-init

zle -N zle-keymap-select auto-fu-zle-keymap-select

unsetopt menu_complete
