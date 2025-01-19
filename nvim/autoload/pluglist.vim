call plug#begin('~/.config/nvim/plugged')

" 必須系
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}

" Appearance
Plug 'itchyny/lightline.vim'
Plug 'Mofiqul/vscode.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'shellRaining/hlchunk.nvim'

" なんか便利系
Plug 'tomtom/tcomment_vim'
Plug 'majutsushi/tagbar'
" Plug 'haya14busa/incsearch.vim'
" Plug 'lighttiger2505/gtags.vim'
Plug 'dyng/ctrlsf.vim'
Plug 'windwp/nvim-autopairs'
Plug 'folke/flash.nvim', { 'tag': 'v1.17.0' }

" Telescope
" Telescope - others
Plug 'nvim-telescope/telescope.nvim'
Plug 'fannheyward/telescope-coc.nvim'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'tom-anders/telescope-vim-bookmarks.nvim'
Plug 'nvim-lua/plenary.nvim'
" Telescope - smart open
Plug 'danielfalk/smart-open.nvim'
Plug 'kkharji/sqlite.lua'

" Git
Plug 'lewis6991/gitsigns.nvim'
Plug 'sindrets/diffview.nvim'

" QuickRun
Plug 'skywind3000/asyncrun.vim'
Plug 'vim-test/vim-test'

" Debugging for go
Plug 'sebdah/vim-delve'

" Moving
Plug 'rhysd/clever-f.vim'
Plug 'smoka7/hop.nvim'

" " Unite
" Plug 'Shougo/unite.vim'
" Plug 'tacroe/unite-mark'
" Plug 'Shougo/neoyank.vim'

" File Search
Plug 'nvim-tree/nvim-tree.lua'
Plug 'stevearc/oil.nvim'
Plug 'nvim-tree/nvim-web-devicons'

" copilot
Plug 'github/copilot.vim'

Plug 'hashivim/vim-terraform' , { 'for': 'terraform'}

call plug#end()
