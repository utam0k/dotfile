export DOTZDIR=~/.zsh.d
export ZCONFDIR=$DOTZDIR/config
export ZPLUGINSDIR=$DOTZDIR/plugins
export LANG=ja_JP.UTF-8
export TERM='xterm-256color'

# for debug var
local let_include=1

if [[ $let_include = 1 ]]; then
    ## load my config files

    function load_conf_file () {
        [[ -f $1 ]] && source $1
    }

    # 関数定義の読み込み
    load_conf_file $ZCONFDIR/conf.myfunction.zsh

    # 色
    load_conf_file $ZCONFDIR/conf.color.zsh

    # プロンプト
    load_conf_file $ZCONFDIR/conf.prompt.zsh

    # 補完
    load_conf_file $ZCONFDIR/conf.completion.zsh

    # プラグイン
    load_conf_file $ZCONFDIR/conf.plugins.zsh

    # キーバインド (aliasの近くを推奨)
    load_conf_file $ZCONFDIR/conf.key-bind.zsh

    # alias (最後にロードすることを推奨)
    load_conf_file $ZCONFDIR/conf.aliases.zsh

fi

## load modules ##
zmodload zsh/complist
zmodload zsh/regex



# share history over other terminals
setopt histignorealldups sharehistory

# memo dir which you changed.
# AND, you can use "cd -[TAB]" !!
setopt auto_pushd
setopt pushd_ignore_dups

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=$DOTZDIR/history/zsh_history


#############################
####     load builtin    ####
#############################

# zed(エディタライク)を使えるようにする
autoload zed


############################
####   basic setting    ####
############################

umask 022

setopt no_beep
setopt transient_rprompt
setopt IGNORE_EOF
setopt brace_ccl           # ex : {a-d} -> a b c d

# setopt auto_cd             # can change directory without 'cd' command

chpwd_functions+=(dirs)

# anyenv
is_exist_cmd anyenv  && is_exist_cmd git && [[ ! -d $(anyenv root)/plugins ]] && {
    mkdir -p $(anyenv root)/plugins
    git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
}

