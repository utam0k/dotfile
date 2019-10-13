zstyle ':zle:*' word-chars "*?_.~-=&!#$%^(){}[]<>./;:@,| "
zstyle ':zle:*' word-style unspecified
zstyle ':completion:*' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' keep-prefix
zstyle ':completion:*' recent-dirs-insert both
zstyle ':completion:*' completer _complete
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.cache/zsh_cache
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache true
zstyle ':completion:*' list-separator '-->'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:sudo:*' command-path /usr/bin
