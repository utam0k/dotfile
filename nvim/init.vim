filetype off

" ここで設定
let g:python3_host_prog = expand('$HOME') . '/.pyenv/shims/python'
" let g:python_host_prog = expand('$HOME') . '/bin/python2'

runtime! autoload/plug.vim
runtime! autoload/pluglist.vim
runtime! userautoload/*.vim
