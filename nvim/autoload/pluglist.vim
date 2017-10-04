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
Plug 'rhysd/committia.vim'

" QuickRun系
Plug 'thinca/vim-quickrun'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }

" 移動系
" Plug 'easymotion/vim-easymotion'
Plug 'rhysd/clever-f.vim'

" Unite
Plug 'Shougo/unite.vim'
Plug 'tacroe/unite-mark'
Plug 'Shougo/neoyank.vim'

" コマンド呼ぶと召喚される系男子
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'rking/ag.vim', { 'on': 'Ag' }

" 言語ごとのプラグイン

" C++
if exists('g:cpp_setting') && cpp_setting == 1
    Plug 'zchee/deoplete-clang', { 'for': 'cpp'}
endif

" Haskell
if exists('g:g:hs_setting') && hs_setting == 1
    Plug 'itchyny/vim-haskell-indent', { 'for': 'haskell'}
    Plug 'ujihisa/neco-ghc', { 'for': 'haskell'}
    Plug 'eagletmt/ghcmod-vim', { 'for': 'haskell'}
endif

" Go
if exists('g:go_setting') && go_setting == 1
    Plug 'fatih/vim-go', { 'for': 'go'}
    Plug 'zchee/deoplete-go', { 'for': 'go'}
endif

" Python
if exists('g:py_setting') && py_setting == 1
    " Plug 'zchee/deoplete-jedi', { 'for': 'python'}
    Plug 'davidhalter/jedi-vim', { 'for': 'python'}
endif

" Rust
if exists('g:rust_setting') && rust_setting == 1
    Plug 'sebastianmarkow/deoplete-rust', { 'for': 'rust' }
    Plug 'rust-lang/rust.vim', { 'for': 'rust' }
endif

" js
if exists('g:js_setting') && js_setting == 1
    Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
    Plug 'mxw/vim-jsx', { 'for': 'javascript' }
endif

call plug#end()
