call plug#begin('~/.config/nvim/plugged')

" 必須系
Plug 'Shougo/deoplete.nvim'

" 見た目
Plug 'w0ng/vim-hybrid'
Plug 'itchyny/lightline.vim'

" なんか便利系
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'wakatime/vim-wakatime'
Plug 'junegunn/vim-easy-align'

" Git
Plug 'tpope/vim-fugitive'

" QuickRun系
Plug 'thinca/vim-quickrun'
Plug 'Shougo/vimproc.vim'

" 移動系
Plug 'easymotion/vim-easymotion'

" Unite
Plug 'Shougo/unite.vim'
Plug 'tacroe/unite-mark'
Plug 'Shougo/neoyank.vim'

" 言語ごとのプラグイン
" Haskell
Plug 'itchyny/vim-haskell-indent', { 'for': 'haskell'}
Plug 'ujihisa/neco-ghc', { 'for': 'haskell'}
Plug 'eagletmt/ghcmod-vim', { 'for': 'haskell'}

call plug#end()
