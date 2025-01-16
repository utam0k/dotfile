set encoding=utf-8

set expandtab

set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent
au BufNewFile,BufRead *.go set noexpandtab tabstop=4 shiftwidth=4

autocmd QuickFixCmdPost *grep* cwindow

set nowrap

set wildmode=list,full

set lazyredraw
set updatetime=1000

set undodir=$HOME/.config/nvim/undo
set undofile
