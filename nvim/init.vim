filetype off

" ここで設定
let g:python3_host_prog = expand('$HOME') . '/.pyenv/shims/python3'
" let g:python_host_prog = expand('$HOME') . '/bin/python2'

if empty(glob('$HOME/.config/autoload/plug.vim'))
  silent !curl -fLo $HOME/.config/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

runtime! autoload/plug.vim
runtime! autoload/pluglist.vim
runtime! userautoload/*.vim
