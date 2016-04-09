# 補完ファイルのpath設定をする before compinit
fpath=($DOTZDIR/plugins/zsh-completions/src $fpath)
fpath=($DOTZDIR/completions $fpath) # 独自の補完ファイル群

## -x: export SUDO_PATHも一緒に行う。
## -T: SUDO_PATHとsudo_pathを連動する。
typeset -xT SUDO_PATH sudo_path
## 重複したパスを登録しない。
typeset -U sudo_path
## (N-/): 存在しないディレクトリは登録しない。
##    パス(...): ...という条件にマッチするパスのみ残す。
##            N: NULL_GLOBオプションを設定。
##               globがマッチしなかったり存在しないパスを無視する。
##            -: シンボリックリンク先のパスを評価。
##            /: ディレクトリのみ残す。
sudo_path=(
    {/usr/pkg,/usr/local,/usr}/sbin(N-/)
    /opt/lampp(N-/)
)


# Use modern completion system
autoload -Uz compinit
compinit -u

setopt auto_list                # 補完キーで補完可能な一覧を表示
setopt auto_menu                # 補完候補の移動をTABで
setopt auto_remove_slash        # /を自動的に消してくれる
setopt complete_aliases         # aliasも補完候補に
setopt complete_in_word         # カーソルで補完
setopt hist_expand              # 補完時にヒストリを自動展開
setopt list_types               # auto_listでファイルの種類毎にマーク表示
setopt list_packed              # 補完候補の表示を詰めて表示
setopt magic_equal_subst        # = の後も補完させる


# 主にデフォルトの設定を使う
zstyle ':completion:*' auto-description 'specify: %d'
#zstyle ':completion:*' completer _expand _complete _correct _approximate _list _prefix
zstyle ':completion:*' completer _complete _list _prefix _expand _oldlist #_history
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
# 補完候補に色を付ける
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# 補完時に大文字小文字を区別しないとか...
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' use-compctl false

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
# 変数の添字を補完するとか
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
# オプション補完の時のセパレータ
zstyle ':completion:*' list-separator '-->'
zstyle ':completion:*:manuals' separate-sections true
# 補完でキャッシュを使うようにする
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $DOTZDIR/cache


if is_exist_cmd pip ; then
    # pipで補完が効くようにする
    # pip zsh completion start
    function _pip_completion {
        local words cword
        read -Ac words
        read -cn cword
        reply=( $( COMP_WORDS="$words[*]" \
                             COMP_CWORD=$(( cword-1 )) \
                             PIP_AUTO_COMPLETE=1 $words[1] ) )
    }
    compctl -K _pip_completion pip
    # pip zsh completion end
fi
