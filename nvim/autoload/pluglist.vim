call plug#begin('~/.config/nvim/plugged')

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'w0ng/vim-hybrid'
Plug 'wakatime/vim-wakatime'
Plug 'Shougo/deoplete.nvim'
Plug 'thinca/vim-quickrun', { 'on': 'QuickRun'}
Plug 'Shougo/vimproc.vim'
Plug 'tpope/vim-fugitive'
Plug 'rhysd/clever-f.vim'
Plug 'junegunn/vim-easy-align'
Plug 'easymotion/vim-easymotion'

"言語ごとのプラグイン
Plug 'itchyny/vim-haskell-indent', { 'for': 'haskell'}
Plug 'ujihisa/neco-ghc', { 'for': 'haskell'}
Plug 'eagletmt/ghcmod-vim', { 'for': 'haskell'}

call plug#end()
