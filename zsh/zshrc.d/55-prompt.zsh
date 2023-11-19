setopt PROMPT_SUBST
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "+"
zstyle ':vcs_info:git:*' unstagedstr "-"

zstyle ':vcs_info:*' formats '[%b%m%u%c]'
zstyle ':vcs_info:*' actionformats '[%b|%a]'

precmd () {
    # Check for WIP commit
    local last_commit_msg=$(git log -1 --pretty=%B 2> /dev/null)
    local wip_indicator=""
    if [[ $last_commit_msg == WIP-* ]]; then
        wip_indicator="%F{yellow}- %f"
    fi

    # Set up VCS info
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"

    # Set PROMPT and RPROMPT
    DEFAULT="%F{green}$%f"
    ERROR="%F{red}$%f"
    PROMPT="${wip_indicator}%(?.${DEFAULT}.${ERROR})%  "
    RPROMPT="%1(v|%F{red}%1v%f|) %F{cyan}%~%f %F{magenta}%n%f"
}

