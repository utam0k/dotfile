call plug#begin('~/.config/nvim/plugged')

" 必須系
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}

" Appearance
Plug 'itchyny/lightline.vim'
Plug 'Mofiqul/vscode.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'shellRaining/hlchunk.nvim'
Plug 'folke/todo-comments.nvim'
Plug 'nvim-lua/plenary.nvim' " For todo-comments

" なんか便利系
Plug 'tomtom/tcomment_vim'
Plug 'majutsushi/tagbar'
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

" For Test
Plug 'nvim-lua/plenary.nvim'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-neotest/nvim-nio'
Plug 'nvim-neotest/neotest'
Plug 'fredrikaverpil/neotest-golang', { 'for': 'go' }
Plug 'rouge8/neotest-rust', { 'for': 'rust' }

" Debugging for go
Plug 'sebdah/vim-delve'

" Moving
Plug 'folke/flash.nvim'

" " Unite
" Plug 'Shougo/unite.vim'
" Plug 'tacroe/unite-mark'
" Plug 'Shougo/neoyank.vim'

" File Search
Plug 'stevearc/oil.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v3.x' }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'
Plug 's1n7ax/nvim-window-picker'

" copilot
Plug 'github/copilot.vim'

Plug 'hashivim/vim-terraform' , { 'for': 'terraform'}

call plug#end()
