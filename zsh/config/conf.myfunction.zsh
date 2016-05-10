
## ZSH関係のコマンド

# zshのmanから検索してくれるやつ
function zman() {
    PAGER="less -g -s '+/^       "$1"'" man zshall
}

# zshを再起動する
function zreload() {
    exec $SHELL
}


## 一般コマンド

# いろいろな拡張子のファイルを解凍するコマンド
function extract () {
    if [ -f $1 ] ; then
        case $1 in
						*.tar.bz2) tar xvjf $1	 ;;
						*.tar.gz)	 tar xvzf $1	 ;;
						*.tar.xz)	 tar xvJf $1	 ;;
						*.bz2)		 bunzip2 $1		 ;;
						*.rar)		 unrar x $1		 ;;
						*.gz)			 gunzip $1		 ;;
						*.tar)		 tar xvf $1		 ;;
						*.tbz2)		 tar xvjf $1	 ;;
						*.tgz)		 tar xvzf $1	 ;;
						*.zip)		 unzip $1			 ;;
						*.Z)			 uncompress $1 ;;
						*.7z)			 7zr x $1			 ;;
						*.lzma)		 lzma -dv $1	 ;;
						*.xz)			 xz -dv $1		 ;;
            *)         echo "don't know how to extract '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

function findgrep() {
    if [[ $# -lt 3 ]]; then
        cat <<EOF
Short of arguments!!
Usege: arg1 -> search path
       arg2 -> file name
       arg3 -> search word
EOF
        return 0
    fi
    find $1 -name $2 -exec grep $3 {} +
}

# cshのsetenvをzshでも
function setenv() { export $1=$2 }

# エイリアスコマンドのオリジナルコマンドを表示
function resolve_alias() {
    local cmd="$1"
    while \
        whence "$cmd" >/dev/null 2>/dev/null \
            && [ "$(whence "$cmd")" != "$cmd" ]
    do
        cmd=$(whence "$cmd")
    done
    echo "$cmd"
}

# ヒットするやつを削除するやつ
function findrm() {
    if [ $# -lt 2 ]; then
        cat <<EOF
Short of arguments!!
Usage: findrm NamePattern DistDir
EOF
        return 0
    fi
    if [ $2 = "" ]; then
        # current dir
        find . -name "$1" -exec rm {} ";"
        return 1
    fi
    find $2 -name "$1" -exec rm {} ";"
}

# 1つ上のディレクトリに移動する
function cdup() {
  if [ -n "$BUFFER" ]; then
    zle self-insert "^"
  else
    echo
    cd ..
    zle reset-prompt
  fi
}


# PATHをスペースで分割したものを掃き出す
function get_split_path(){
    # sed -e 's/:/ /g' => 文字列中の':'を' 'で置換
    echo $PATH | sed -e 's/:/ /g'
}

# カレントディレクトリの一覧をリストで取得する
function get_current_directories() {
    echo `ls -al | awk '$1 ~ /^d/ {print $9}'`
}

# emacsが起動してるかどうか
function is_emacs() {
    [[ "$EMACS" != "" ]]
}

# emacs上のシェルが起動してるかどうか
function is_eterm(){
    [[ "$TERM" = "eterm-color" ]]
}

# screenが起動してるかどうか
function is_screen_running() {
    # tscreen also uses this varariable.
    [ ! -z "$WINDOW" ]
}

# tmuxが起動してるかどうか
function is_tmux_runnning() {
    [ ! -z "$TMUX" ]
}

# コマンドが存在するかをチェック
function is_exist_cmd () {
    [[ ${+commands[$1]} = 1 ]]
}

# ファイルが存在するかをチェック
function is_exist_file () {
    [[ -f $1 ]]
}

# 複数のキーマップにまとめてキーバインドを設定する関数
# $1  --> bind-key
# $2  --> command
# $3~ --> keymaps
function reg-key () {
    if [ $# -eq 2 ]; then
        bindkey $1 $2
        return 1
    elif [ $# -lt 2 ]; then
        echo "Usage: key_register KEY CMD KEYMAP(1) [ ... KEYMAP(n)]"
        return 0
    fi
    for kmap in "$@" ;do
        if [ "$kmap" != "$1" -a "$kmap" != "$2" ]; then
            bindkey -M "$kmap" "$1" "$2"
        fi
    done
    return 1
}

# 引数に渡した文字列をコマンドラインに展開する関数
# ただし，適当な関数を介さないといけない欠点がある?
# usage : てきとうなコマンドを定義しておく
# 例:----------------------------------------
# function insert_git() { insert_cmd_in_line "git"; }
# zle -N insert_git
# bindkey "^P" insert_git
# ------------------------------------------
# これを適当なキーに割り当て，それを実行すると...
# $ git[space]■
function insert_cmd_in_line () {
    if [ $# = 0 ]; then
        echo "Usage: cmdins 'CMD and OPTIONs'"
        return 0
    fi
    BUFFER="$1 "
    CURSOR=$#BUFFER
}

# 前景色のサンプルを表示する関数
function disp-color-list-FG() {
    local nn
    for nn in {016..255}
    do
        echo -n "\e[0;38;5;${nn}m${nn}\e[m"
        [ `expr ${nn} % 8` -eq 7 ] && echo "" || echo -n " "
    done
    echo ""
}

# 背景色のサンプルを表示する関数
function disp-color-list-BG() {
    local nn
    for nn in {016..255}
    do
        echo -n "\e[0;48;5;${nn}m${nn}\e[m"
        [ `expr ${nn} % 8` -eq 7 ] && echo "" || echo -n " "
    done
    echo ""
}

# get the name of the branch we are on
function git_prompt_info() {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}


# Checks if working tree is dirty
parse_git_dirty() {
  if [[ $(check_git_dirty) -eq 0 ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  else
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  fi
}

check_git_dirty() {
  local SUBMODULE_SYNTAX=''
  local GIT_STATUS=''
  local EXITSTATUS=0

  if [[ $POST_1_7_2_GIT -gt 0 ]]; then
    SUBMODULE_SYNTAX="--ignore-submodules=dirty"
  fi
  GIT_STATUS=$(command git status -s ${SUBMODULE_SYNTAX} 2> /dev/null | tail -n1)
  if [[ -n $GIT_STATUS ]]; then
    EXITSTATUS=1
  fi

  echo $EXITSTATUS
  return $EXITSTATUS
}

# get the difference between the local and remote branches
git_remote_status() {
  remote=${$(command git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}
  if [[ -n ${remote} ]] ; then
    ahead=$(command git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
    behind=$(command git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)

    if [ $ahead -eq 0 ] && [ $behind -gt 0 ]
    then
        echo "$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE"
    elif [ $ahead -gt 0 ] && [ $behind -eq 0 ]
    then
        echo "$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE"
    elif [ $ahead -gt 0 ] && [ $behind -gt 0 ]
    then
        echo "$ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE"
    fi
  fi
}

# Checks if there are commits ahead from remote
function git_prompt_ahead() {
  if $(echo "$(command git log origin/$(current_branch)..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
    echo "$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
}

# Formats prompt string for current git commit short SHA
function git_prompt_short_sha() {
  SHA=$(command git rev-parse --short HEAD 2> /dev/null) && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Formats prompt string for current git commit long SHA
function git_prompt_long_sha() {
  SHA=$(command git rev-parse HEAD 2> /dev/null) && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Get the status of the working tree
git_prompt_status() {
  INDEX=$(command git status --porcelain -b 2> /dev/null)
  STATUS=""
  if $(echo "$INDEX" | grep -E '^\?\? ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^D  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^AD ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  fi
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    STATUS="$ZSH_THEME_GIT_PROMPT_STASHED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## .*ahead' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## .*behind' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_BEHIND$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## .*diverged' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DIVERGED$STATUS"
  fi
  echo $STATUS
}

#compare the provided version of git to the version installed and on path
#prints 1 if input version <= installed version
#prints -1 otherwise
function git_compare_version() {
  local INPUT_GIT_VERSION=$1;
  local INSTALLED_GIT_VERSION
  INPUT_GIT_VERSION=(${(s/./)INPUT_GIT_VERSION});
  INSTALLED_GIT_VERSION=($(command git --version 2>/dev/null));
  INSTALLED_GIT_VERSION=(${(s/./)INSTALLED_GIT_VERSION[3]});

  for i in {1..3}; do
    if [[ $INSTALLED_GIT_VERSION[$i] -lt $INPUT_GIT_VERSION[$i] ]]; then
      echo -1
      return 0
    fi
  done
  echo 1
}

function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

#this is unlikely to change so make it all statically assigned
POST_1_7_2_GIT=$(git_compare_version "1.7.2")
#clean up the namespace slightly by removing the checker function
unset -f git_compare_version
