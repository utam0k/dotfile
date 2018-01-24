has() {
	type "$1" > /dev/null 2>&1
}

if type vim > /dev/null 2>&1; then
	export EDITOR='nvim'
	export GIT_EDITOR='nvim'
	alias vi='nvim'
else
	export EDITOR='vi'
	export GIT_EDITOR='vi'
fi

if [ -r ~/.zshenv.local ]; then
	. ~/.zshenv.local
fi
export EDITOR='nvim'
