##########################
###   Prompt Setting   ###
##########################
setopt prompt_subst 
ZSH_THEME_GIT_PROMPT_DIRTY='±'

function _git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
  echo "${ref/refs\/heads\// }$(parse_git_dirty)"
}

function _git_info() {
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    local BG_COLOR=green
    if [[ -n $(parse_git_dirty) ]]; then
      BG_COLOR=yellow
      FG_COLOR=white
    fi

    if [[ ! -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then BG_COLOR=cyan
        FG_COLOR=gray
    fi
    # echo "%{%K{$BG_COLOR}%}%{%F{$FG_COLOR}%} $(_git_prompt_info) %{%F{$BG_COLOR}%K{blue}%}"
    echo "%{%F{$FG_COLOR}%} $(_git_prompt_info) %{%K{blue}%}"
  else
    echo "%{%K{blue}%}"
  fi
}

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

PROMPT_HOST='%{%b%F{white}%K{gray}%} %(?.%{%F{green}%}✔.%{%F{red}%}✘)%{%F{yellow}%} %n %{%F{black}%}'
# PROMPT_DIR='%{%F{white}%} %~%  '
PROMPT_DIR='%{%F{gray}%} %~%  '
PROMPT_SU='%(!.%{%k%F{blue}%K{black}%}%{%F{yellow}%} ⚡ %{%k%F{black}%}.%{%k%F{blue}%})%{%f%k%b%}'

# PROMPT='%{%f%b%k%}$PROMPT_HOST$(_git_info)$PROMPT_DIR$PROMPT_SU
PROMPT='%{%f%b%k%}$PROMPT_HOST%{%K{blue}%}$PROMPT_DIR$PROMPT_SU
%(?.%B%F{white}.%B%F{blue})%(?!(๑˃̵ᴗ˂̵)ﻭ < !(;^ω^%) < )%f%b'
RPROMPT='$(_git_info)'
# RPROMPT='%{$fg[green]%}[%*]%{$reset_color%}'
