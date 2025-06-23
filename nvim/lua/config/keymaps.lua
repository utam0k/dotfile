-- Keymaps configuration
-- This file contains the core keybindings for Neovim

-- Editor options (not keymaps, but related to input behavior)
vim.opt.backspace = "indent,eol,start"

-- Helper function for creating keymaps with consistent defaults
local function map(mode, lhs, rhs, opts)
	opts = opts or {}
	opts.noremap = opts.noremap ~= false -- default to true
	opts.silent = opts.silent ~= false -- default to true
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- Helper function for creating numbered mappings
local function create_numbered_mappings(prefix, count, callback, desc_template)
	for i = 1, count do
		map("n", prefix .. i, function()
			callback(i)
		end, { desc = desc_template:format(i) })
	end
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
create_numbered_mappings("z", 9, function(i)
	vim.cmd("normal! zt")
	vim.cmd("normal! " .. i .. "")
end, "Scroll to top and move %d lines down")

-- ============================================================================
-- TAB MANAGEMENT
-- ============================================================================

-- Disable 't' as a prefix key to avoid conflicts
map("n", "t", "<Nop>", { desc = "Tab prefix (disabled)" })

-- Tab navigation by number (1-9)
create_numbered_mappings("t", 9, function(i)
	vim.cmd("tabnext " .. i)
end, "Go to tab %d")

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
		vim.cmd([[<C-\><C-n>]])
		vim.cmd("tabnext " .. i)
	end, { desc = "Go to tab " .. i .. " from terminal" })
end

-- ============================================================================
-- GIT NAVIGATION
-- ============================================================================

-- Navigate git hunks (changes)
-- Helper function for git hunk navigation with fallback
local function navigate_git_hunk(direction)
	local ok, mini_diff = pcall(require, "mini.diff")
	if ok then
		mini_diff.goto_hunk(direction)
	else
		-- Try gitsigns as fallback
		local gs_ok, gitsigns = pcall(require, "gitsigns")
		if gs_ok then
			if direction == "prev" then
				gitsigns.prev_hunk()
			else
				gitsigns.next_hunk()
			end
		else
			vim.notify("No diff plugin available", vim.log.levels.WARN)
		end
	end
end

-- Map both [g and g[ to previous hunk
map("n", "[g", function()
	navigate_git_hunk("prev")
end, { desc = "Go to previous git hunk" })
map("n", "g[", function()
	navigate_git_hunk("prev")
end, { desc = "Go to previous git hunk" })

-- Map both ]g and g] to next hunk
map("n", "]g", function()
	navigate_git_hunk("next")
end, { desc = "Go to next git hunk" })
map("n", "g]", function()
	navigate_git_hunk("next")
end, { desc = "Go to next git hunk" })

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
-- Window resizing with arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

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

-- Quickfix list navigation
map("n", "<leader>co", "<cmd>copen<cr>", { desc = "Open quickfix list" })
map("n", "<leader>cc", "<cmd>cclose<cr>", { desc = "Close quickfix list" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Previous quickfix item" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })

-- ============================================================================
-- MISCELLANEOUS
-- ============================================================================

-- Replace word under cursor
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

-- Make file executable
map("n", "<leader>x", "<cmd>!chmod +x %<cr>", { desc = "Make file executable" })

-- Source current file (useful for config files)
map("n", "<leader><leader>", function()
	vim.cmd("source %")
	vim.notify("File sourced!", vim.log.levels.INFO)
end, { desc = "Source current file" })

-- ============================================================================
-- GIT DIFFVIEW
-- ============================================================================

-- DiffView alias
vim.cmd("command! DV DiffviewOpen")
