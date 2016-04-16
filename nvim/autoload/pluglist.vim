call plug#begin('~/.config/nvim/plugged')

" 必須系
Plug 'Shougo/deoplete.nvim'
Plug 'w0ng/vim-hybrid'

" なんかオプション
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'wakatime/vim-wakatime'
Plug 'junegunn/vim-easy-align'

" Git
Plug 'tpope/vim-fugitive'

" QuickRun系
Plug 'thinca/vim-quickrun', { 'on': 'QuickRun'}
Plug 'Shougo/vimproc.vim', { 'on': 'QuickRun'}

" 移動系
Plug 'rhysd/clever-f.vim'
Plug 'easymotion/vim-easymotion'

" Unite
Plug 'Shougo/unite.vim', { 'on': 'Unite'}
Plug 'tacroe/unite-mark', { 'on': 'Unite'}

" 言語ごとのプラグイン
" Haskell
Plug 'itchyny/vim-haskell-indent', { 'for': 'haskell'}
Plug 'ujihisa/neco-ghc', { 'for': 'haskell'}
Plug 'eagletmt/ghcmod-vim', { 'for': 'haskell'}

call plug#end()
