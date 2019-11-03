HISTFILE=~/.zsh_history
HISTSIZE=100000000
SAVEHIST=${HISTSIZE}
if command -v nvim > /dev/null; then
    EDITOR=$(which nvim)
elif command -v vim > /dev/null; then
    EDITOR=$(which vim)
else
    EIDTOR=$(which vi)
fi
