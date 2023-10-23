call plug#begin('~/.config/nvim/plugged')

" 必須系
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}

" 見た目
Plug 'itchyny/lightline.vim'
Plug 'morhetz/gruvbox'

" なんか便利系
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
Plug 'sindrets/diffview.nvim'

" QuickRun
Plug 'skywind3000/asyncrun.vim'
Plug 'vim-test/vim-test'

" Debugging for go
Plug 'sebdah/vim-delve'

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
" Plug 'github/copilot.vim'

Plug 'hashivim/vim-terraform' , { 'for': 'terraform'}

call plug#end()
