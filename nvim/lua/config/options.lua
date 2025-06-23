-- Editor options
local opt = vim.opt

-- Indentation (4 spaces by default, can be overridden by ftplugin or editorconfig)
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true

-- Display
opt.wrap = false
opt.wildmode = "list,full"

-- Performance
opt.updatetime = 300 -- Faster CursorHold for auto-reload

-- Diff options for better code review (using only supported options)
vim.cmd([[
  set diffopt+=algorithm:patience
  set diffopt+=indent-heuristic
]])

-- Persistent undo
opt.undodir = vim.fn.expand("$HOME/.config/nvim/undo")
opt.undofile = true

-- File handling
opt.autoread = true -- Automatically read file when changed outside of Vim
opt.backup = false -- Don't create backup files
opt.swapfile = false -- Don't create swap files

-- Disable tags
opt.tags = "" -- Prevents E433 error when no tags file exists

-- Appearance
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.mouse = "" -- Disable mouse support
opt.cursorline = true -- Highlight current line
opt.background = "dark" -- Tell plugins we prefer dark colorschemes
opt.number = true -- Show line numbers
opt.cmdheight = 0 -- Hide command line when not in use
opt.showmode = false -- Don't show mode in command line
opt.laststatus = 0 -- Hide statusline completely

-- Suppress file messages
opt.shortmess:append("F") -- Don't give file info when editing a file
opt.shortmess:append("c") -- Don't give completion menu messages
opt.report = 99999 -- Threshold for reporting number of changed lines (effectively disable)

-- Python host programs for plugins that need Python support
vim.g.python_host_prog = vim.fn.expand("$HOME/.pyenv/versions/nvim/bin/python")
vim.g.python3_host_prog = vim.fn.expand("$HOME/.pyenv/versions/nvim/bin/python")
