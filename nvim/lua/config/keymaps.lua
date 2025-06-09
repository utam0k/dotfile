-- Keymaps configuration
-- This file contains the core keybindings for Neovim

-- Set leader keys first (before any mappings that use them)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Editor options (not keymaps, but related to input behavior)
vim.opt.backspace = "indent,eol,start"

-- Helper function for creating keymaps with consistent defaults
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap ~= false -- default to true
  opts.silent = opts.silent ~= false -- default to true
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ============================================================================
-- INSERT MODE
-- ============================================================================

-- Quick escape and navigation
map("i", "<C-J>", "<ESC>", { desc = "Exit insert mode" })
map("i", "<C-l>", "<Right>", { desc = "Move cursor right" })
map("i", "<C-h>", "<Left>", { desc = "Move cursor left" })

-- ============================================================================
-- NORMAL MODE - Basic Navigation
-- ============================================================================

-- Command mode shortcut
map("n", ";", ":", { desc = "Enter command mode" })

-- Line navigation with Space
map("n", "<Space>h", "^", { desc = "Jump to first non-blank character" })
map("n", "<Space>l", "$", { desc = "Jump to end of line" })
map("n", "<Space>/", "*", { desc = "Search word under cursor" })
map("n", "<Space>m", "%", { desc = "Jump to matching bracket" })

-- Clear search highlighting
map("n", "<C-J><C-J>", function()
  vim.cmd.nohlsearch()
end, { desc = "Clear search highlight" })

-- ============================================================================
-- NORMAL MODE - Viewport Scrolling
-- ============================================================================

-- Create numbered z mappings for precise scrolling
for i = 1, 9 do
  map("n", "z" .. i, function()
    vim.cmd("normal! zt")
    vim.cmd("normal! " .. i .. "")
  end, { desc = "Scroll to top and move " .. i .. " lines down" })
end

-- ============================================================================
-- TAB MANAGEMENT
-- ============================================================================

-- Disable 't' as a prefix key to avoid conflicts
map("n", "t", "<Nop>", { desc = "Tab prefix (disabled)" })

-- Tab navigation by number (1-9)
for i = 1, 9 do
  map("n", "t" .. i, function()
    vim.cmd("tabnext " .. i)
  end, { desc = "Go to tab " .. i })
end

-- Tab management commands
map("n", "tc", function()
  vim.cmd("tablast")
  vim.cmd("tabnew")
  -- Trigger telescope after creating new tab
  vim.defer_fn(function()
    vim.cmd("Telescope smart_open")
  end, 50)
end, { desc = "Create new tab and open file picker" })

map("n", "tx", function()
  vim.cmd("tabclose")
end, { desc = "Close current tab" })

map("n", "tn", function()
  vim.cmd("tabnext")
end, { desc = "Go to next tab" })

map("n", "tp", function()
  vim.cmd("tabprevious")
end, { desc = "Go to previous tab" })

-- ============================================================================
-- TERMINAL MODE
-- ============================================================================

-- Exit terminal mode
map("t", "<ESC>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("t", "<C-]>", [[<C-\><C-n>]], { desc = "Exit terminal mode (alternative)" })

-- Terminal tab navigation (1-9)
for i = 1, 9 do
  map("t", "t" .. i, function()
    vim.cmd([[normal! <C-\><C-n>]])
    vim.cmd("tabnext " .. i)
  end, { desc = "Go to tab " .. i .. " from terminal" })
end

-- ============================================================================
-- DIAGNOSTICS (Global keymaps, LSP-specific ones are in lspconfig.lua)
-- ============================================================================

-- Navigate diagnostics
map("n", "[d", function()
  vim.diagnostic.goto_prev()
end, { desc = "Go to previous diagnostic" })

map("n", "]d", function()
  vim.diagnostic.goto_next()
end, { desc = "Go to next diagnostic" })

map("n", "<leader>e", function()
  vim.diagnostic.open_float()
end, { desc = "Show diagnostic in floating window" })

map("n", "<leader>q", function()
  vim.diagnostic.setloclist()
end, { desc = "Add diagnostics to location list" })

-- ============================================================================
-- WINDOW MANAGEMENT
-- ============================================================================

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Navigate to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Navigate to window below" })
map("n", "<C-k>", "<C-w>k", { desc = "Navigate to window above" })
map("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window" })

-- Window resizing
map("n", "<C-Up>", function()
  vim.cmd("resize +2")
end, { desc = "Increase window height" })

map("n", "<C-Down>", function()
  vim.cmd("resize -2")
end, { desc = "Decrease window height" })

map("n", "<C-Left>", function()
  vim.cmd("vertical resize -2")
end, { desc = "Decrease window width" })

map("n", "<C-Right>", function()
  vim.cmd("vertical resize +2")
end, { desc = "Increase window width" })

-- ============================================================================
-- VISUAL MODE
-- ============================================================================

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move selected lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ============================================================================
-- TEXT MANIPULATION
-- ============================================================================

-- Join lines without moving cursor
map("n", "J", "mzJ`z", { desc = "Join lines (cursor stays)" })

-- Center screen after navigation
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- ============================================================================
-- CLIPBOARD OPERATIONS
-- ============================================================================

-- System clipboard integration
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from system clipboard" })
map({ "n", "v" }, "<leader>P", [["+P]], { desc = "Paste before from system clipboard" })

-- Delete without yanking
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- ============================================================================
-- QUICKFIX AND LOCATION LIST
-- ============================================================================

map("n", "<leader>co", function()
  vim.cmd("copen")
end, { desc = "Open quickfix list" })

map("n", "<leader>cc", function()
  vim.cmd("cclose")
end, { desc = "Close quickfix list" })

map("n", "[q", function()
  vim.cmd("cprev")
end, { desc = "Previous quickfix item" })

map("n", "]q", function()
  vim.cmd("cnext")
end, { desc = "Next quickfix item" })

-- ============================================================================
-- MISCELLANEOUS
-- ============================================================================

-- Replace word under cursor
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

-- Make file executable
map("n", "<leader>x", function()
  vim.cmd("!chmod +x %")
end, { desc = "Make file executable" })

-- Source current file (useful for config files)
map("n", "<leader><leader>", function()
  vim.cmd("source %")
  print("File sourced!")
end, { desc = "Source current file" })
