setopt PROMPT_SUBST
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "+"
zstyle ':vcs_info:git:*' unstagedstr "-"

zstyle ':vcs_info:*' formats '[%b%m%u%c]'
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () {
	psvar=()
	LANG=en_US.UTF-8 vcs_info
	[[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"

	DEFAULT=$'%F{green}$%f'
	ERROR=$'%F{red}$%f'
	PROMPT=$'%(?.${DEFAULT}.${ERROR}) '
	RPROMPT="%1(v|%F{red}%1v%f|) %F{cyan}%~%f %F{magenta}%n%f"
}
