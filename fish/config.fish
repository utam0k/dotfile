# Path to Oh My Fish install.
set -gx OMF_PATH "/home/utam0k/.local/share/omf"

# Customize Oh My Fish configuration path.
#set -gx OMF_CONFIG "/home/utam0k/.config/omf"

# Load oh-my-fish configuration.
source $OMF_PATH/init.fish
set fish_theme yimmy
set fish_plugins theme git tmux peco z

alias vi="nvim"
alias l="ls -l"

set CD_HISTORY_FILE $HOME/.cd_history # cd 履歴の記録先ファイル
function percol_cd_history
  sort $CD_HISTORY_FILE | uniq -c | sort -r | sed -e 's/^[ ]*[0-9]*[ ]*//' | peco | read -l percolCDhistory
  if [ $percolCDhistory ]
    commandline 'cd '
    commandline -i $percolCDhistory
    # cd $percolCDhistory
    # echo 'cd' $percolCDhistory
    # echo $percolCDhistory
    commandline -f repaint
  else
    commandline ''
  end
end

function cd
  echo $PWD >> $CD_HISTORY_FILE
  builtin cd $argv
end

function fish_user_key_bindings
  bind \cr peco_select_history
  bind \cd percol_cd_history
end

