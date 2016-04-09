# zaw
# git clone git://github.com/zsh-users/zaw.git

# cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-pushd true

source $DOTZDIR/plugins/zaw/zaw.zsh
zstyle ':filter-select' case-insensitive yes # 大文字小文字を区別しない
