-- Keymaps configuration
local keymap = vim.keymap

-- From keymap.vim
vim.opt.backspace = "indent,eol,start"

-- Insert mode mappings
keymap.set("i", "<C-J>", "<ESC>")
keymap.set("i", "<C-l>", "<Right>")
keymap.set("i", "<C-h>", "<Left>")

-- Normal mode mappings
keymap.set("n", ";", ":")

-- Create numbered z mappings
for i = 1, 9 do
  keymap.set("n", "z" .. i, "zt" .. i .. "<C-Y>")
end

-- Space mappings
keymap.set("n", "<Space>h", "^")
keymap.set("n", "<Space>l", "$")
keymap.set("n", "<Space>/", "*")
keymap.set("n", "<Space>m", "%")

-- Clear search highlight
keymap.set("n", "<C-J><C-J>", ":noh<CR>")

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Tab navigation
keymap.set("n", "t", "<Nop>")
for i = 1, 9 do
  keymap.set("n", "t" .. i, ":<C-u>tabnext" .. i .. "<CR>", { silent = true })
end

keymap.set("n", "tc", ":tablast <bar> tabnew <CR> <Space>p", { silent = true, desc = "New tab" })
keymap.set("n", "tx", ":tabclose<CR>", { silent = true, desc = "Close tab" })
keymap.set("n", "tn", ":tabnext<CR>", { silent = true, desc = "Next tab" })
keymap.set("n", "tp", ":tabprevious<CR>", { silent = true, desc = "Previous tab" })

-- Terminal mode mappings
keymap.set("t", "<ESC>", "<C-\\><C-n>", { silent = true })
keymap.set("t", "<C-]>", "<C-\\><C-n>", { silent = true })

-- Terminal tab navigation
for i = 1, 9 do
  keymap.set("t", "t" .. i, "<C-\\><C-n>:<C-u>tabnext" .. i .. "<CR>")
end