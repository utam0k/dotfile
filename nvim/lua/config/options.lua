-- Editor options
local opt = vim.opt

-- Encoding
opt.encoding = "utf-8"

-- Indentation
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.autoindent = true
opt.smartindent = true

-- Display
opt.wrap = false
opt.wildmode = "list,full"

-- Performance
opt.lazyredraw = true
opt.updatetime = 1000

-- Undo
opt.undodir = vim.fn.expand("$HOME/.config/nvim/undo")
opt.undofile = true

-- Appearance settings
opt.termguicolors = true
opt.mouse = ""
opt.cursorline = true
opt.background = "dark"
opt.laststatus = 2
opt.number = true
vim.cmd("syntax on")

-- Additional settings from config.vim
vim.g.py_setting = 1
vim.g.rust_setting = 1
vim.g.go_setting = 1
vim.g.cpp_setting = 1
vim.g.hs_setting = 1
vim.g.scala_setting = 1

-- Python host programs
vim.g.python_host_prog = vim.fn.expand("$HOME/.pyenv/versions/nvim/bin/python")
vim.g.python3_host_prog = vim.fn.expand("$HOME/.pyenv/versions/nvim/bin/python")