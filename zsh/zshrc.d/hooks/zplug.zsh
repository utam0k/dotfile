cd `dirname $0`
echo $(dirname $0) >&2

if [[ ! -d ../../zplug ]] ;then
    echo zplug not found >&2
    exit
fi

export ZPLUG_HOME="$PWD/../../zplug"
export ZPLUG_REPOS="$PWD/../../build/zsh-plugins"
export ZPLUG_BIN=$ZPLUG_REPOS/bin

source $ZPLUG_HOME/init.zsh

plugins=("zsh-users/zsh-autosuggestions" "zsh-users/zsh-completions" "zsh-users/zsh-syntax-highlighting")

for p in $plugins; do
    zplug "$p"
done


zplug check --verbose >&2 || zplug install >&2
zplug update >&2

zplug load --verbose >&2
zplug clear >&2

echo "##### zplug #####"

for plugin in $plugins; do
    echo source $(ls $PWD/../../build/zsh-plugins/$plugin/*.zsh | /usr/bin/head -n1)
done

echo "##### /zplug #####"
