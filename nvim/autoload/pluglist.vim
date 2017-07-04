call plug#begin('~/.config/nvim/plugged')

" 必須系
Plug 'Shougo/deoplete.nvim'

" 見た目
Plug 'w0ng/vim-hybrid'
Plug 'itchyny/lightline.vim'

" なんか便利系
" Plug 'junegunn/vim-easy-align'
Plug 'Shougo/vimshell.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'Townk/vim-autoclose'
Plug 'tomtom/tcomment_vim'

" Git
Plug 'tpope/vim-fugitive'

" QuickRun系
Plug 'thinca/vim-quickrun'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }

" 移動系
" Plug 'easymotion/vim-easymotion'
" Plug 'rhysd/clever-f.vim'

" Unite
" Plug 'Shougo/unite.vim'
" Plug 'tacroe/unite-mark'
" Plug 'Shougo/neoyank.vim'

" コマンド呼ぶと召喚される系男子
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'rking/ag.vim', { 'on': 'Ag' }

" 言語ごとのプラグイン

" Haskell
Plug 'itchyny/vim-haskell-indent', { 'for': 'haskell'}
Plug 'ujihisa/neco-ghc', { 'for': 'haskell'}
Plug 'eagletmt/ghcmod-vim', { 'for': 'haskell'}

" Go
Plug 'fatih/vim-go', { 'for': 'go'}

" Python
Plug 'davidhalter/jedi-vim', { 'for': 'python'}

call plug#end()
