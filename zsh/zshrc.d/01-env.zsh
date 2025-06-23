HISTFILE=~/.zsh_history
HISTSIZE=100000000
SAVEHIST=${HISTSIZE}
if command -v nvim > /dev/null; then
    export EDITOR=$(which nvim)
elif command -v vim > /dev/null; then
    export EDITOR=$(which vim)
else
    export EDITOR=$(which vi)
fi

autoload -Uz compinit && compinit
