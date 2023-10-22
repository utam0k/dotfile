call plug#begin('~/.config/nvim/plugged')

" 必須系
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}

" 見た目
Plug 'w0ng/vim-hybrid'
Plug 'itchyny/lightline.vim'

" なんか便利系
Plug 'Townk/vim-autoclose'
Plug 'tomtom/tcomment_vim'
Plug 'majutsushi/tagbar'
Plug 'haya14busa/incsearch.vim'
Plug 'lighttiger2505/gtags.vim'
Plug 'dyng/ctrlsf.vim'

Plug 'MattesGroeger/vim-bookmarks'
Plug 'tom-anders/telescope-vim-bookmarks.nvim'

Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'

" Git
Plug 'tpope/vim-fugitive'
Plug 'rhysd/committia.vim'
Plug 'airblade/vim-gitgutter'

" QuickRun
Plug 'skywind3000/asyncrun.vim'
Plug 'vim-test/vim-test'

" Debugging for go
Plug 'sebdah/vim-delve'
" Plug 'benmills/vimux'

" 移動系
Plug 'rhysd/clever-f.vim'

" Unite
Plug 'Shougo/unite.vim'
Plug 'tacroe/unite-mark'
Plug 'Shougo/neoyank.vim'

" コマンド呼ぶと召喚される系
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'

" copilot
Plug 'github/copilot.vim'

" 言語ごとのプラグイン

" Haskell
if exists('g:g:hs_setting') && hs_setting == 1
    Plug 'itchyny/vim-haskell-indent', { 'for': 'haskell'}
    Plug 'ujihisa/neco-ghc', { 'for': 'haskell'}
    Plug 'eagletmt/ghcmod-vim', { 'for': 'haskell'}
endif

" Go
if exists('g:go_setting') && go_setting == 1
    " Plug 'fatih/vim-go', { 'for': 'go'}
    " Plug 'zchee/deoplete-go', { 'for': 'go'}
endif

" Python
if exists('g:py_setting') && py_setting == 1
    Plug 'davidhalter/jedi-vim', { 'for': 'python'}
    " Plug 'zchee/deoplete-jedi', { 'for': 'python'}
endif

" Rust
if exists('g:rust_setting') && rust_setting == 1
    " Plug 'sebastianmarkow/deoplete-rust', { 'for': 'rust' }
    " Plug 'rust-lang/rust.vim', { 'for': 'rust' }
endif

" js
if exists('g:js_setting') && js_setting == 1
    Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
    Plug 'mxw/vim-jsx', { 'for': 'javascript' }
endif

" Scala
if exists('g:scala_setting') && scala_setting == 1
    Plug 'derekwyatt/vim-scala', { 'for': 'scala' }
endif

call plug#end()
