if ! typeset -f fixssh >/dev/null 2>&1; then
    fixssh() {
        eval $(tmux show-env |
        sed -n 's/^\(SSH_[^=]*\)=\(.*\)/export \1="\2"/p')
    }
fi

_fixssh_precmd() {
    [[ -z $TMUX ]] && return
    [[ -z $SSH_CONNECTION && -z $SSH_CLIENT && -z $SSH_TTY ]] && return
    command -v tmux >/dev/null 2>&1 || return
    fixssh
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _fixssh_precmd
