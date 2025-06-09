-- Editor options
local opt = vim.opt

-- Indentation (4 spaces by default, can be overridden by ftplugin or editorconfig)
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true  -- autoindent is enabled by default in Neovim

-- Display
opt.wrap = false
opt.wildmode = "list,full"

-- Performance
opt.updatetime = 300  -- Faster CursorHold for auto-reload (default is 4000)

-- Persistent undo
opt.undodir = vim.fn.expand("$HOME/.config/nvim/undo")
opt.undofile = true

-- File handling
opt.autoread = true -- Automatically read file when changed outside of Vim
opt.backup = false  -- Don't create backup files
opt.swapfile = false -- Don't create swap files

-- Appearance
opt.termguicolors = true  -- Enable 24-bit RGB colors
opt.mouse = ""            -- Disable mouse support
opt.cursorline = true     -- Highlight current line
opt.background = "dark"   -- Tell plugins we prefer dark colorschemes
opt.number = true         -- Show line numbers
-- Note: 'laststatus=2' is the default in Neovim (always show statusline)
-- Note: 'syntax on' is not needed when using treesitter for highlighting
-- Note: 'encoding=utf-8' is the default in Neovim
-- Note: 'lazyredraw' is deprecated in Neovim and has no effect

-- Python host programs for plugins that need Python support
vim.g.python_host_prog = vim.fn.expand("$HOME/.pyenv/versions/nvim/bin/python")
vim.g.python3_host_prog = vim.fn.expand("$HOME/.pyenv/versions/nvim/bin/python")
