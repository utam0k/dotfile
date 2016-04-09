#########################
#####    Aliases   ######
#########################
case "${OSTYPE}" in
freebsd*|darwin*)               # TODO : ls option in freebsd
  alias ls='ls -G -w'
  ;;
linux*)
  alias ls='ls --color=auto'
  ;;
esac
alias la='ls -A'
alias ll='ls -l'
alias lal='ls -Al'

alias userlist='cut -d: -f1 /etc/passwd'

is_exist_cmd emacs && alias e=emacs
is_exist_cmd nvim   && alias v=nvim
is_exist_cmd nvim   && alias vi=nvim


# グローバルエイリアス(コマンドのどこでも展開してくれるやつ)
# ex) ls | grep "hoge"  ==  ls G "hoge"
alias -g G=' | grep '
alias -g L=' | less '



# 拡張子(suffix)と動作の登録
# ./[ファイルの基本名].[登録した拡張子] をすると紐付けされた動作を行う
alias -s py=python
alias -s rb=ruby
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,7z,tar,arj,lzma,xz}=extract
