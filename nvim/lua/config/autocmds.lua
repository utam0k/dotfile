-- Autocommands
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Create augroup
local general = augroup("General", { clear = true })

-- Open quickfix window automatically after grep commands
autocmd("QuickFixCmdPost", {
	pattern = "*grep*",
	callback = function()
		vim.cmd("cwindow")
	end,
	group = general,
	desc = "Open quickfix window after grep",
})

-- Highlight cursor line only in active window
autocmd("WinLeave", {
	callback = function()
		vim.opt_local.cursorline = false
	end,
	group = general,
	desc = "Disable cursorline in inactive windows",
})

autocmd({ "WinEnter", "BufWinEnter" }, {
	callback = function()
		vim.opt_local.cursorline = true
	end,
	group = general,
	desc = "Enable cursorline in active window",
})

-- Auto-reload files when changed externally
-- Note: dropped CursorHold/CursorHoldI — checktime fires per-keystroke pause
-- via FixCursorHold (updatetime=100), causing constant disk stat() calls.
autocmd({ "FocusGained", "BufEnter" }, {
	group = general,
	pattern = "*",
	callback = function()
		if vim.fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
	desc = "Check for file changes outside of Vim",
})

-- Notify when file changed
autocmd("FileChangedShellPost", {
	group = general,
	pattern = "*",
	callback = function(args)
		local message = "File changed on disk."
		if vim.bo[args.buf].modified then
			message = message .. " Unsaved edits kept."
		end
		vim.api.nvim_echo({ { message, "WarningMsg" } }, true, {})
	end,
	desc = "Notify about external changes without claiming the buffer was reloaded",
})

-- Auto-resize splits when terminal window changes size
local auto_equal_group = augroup("AutoResizeSplits", { clear = true })

autocmd("VimResized", {
	group = auto_equal_group,
	callback = function()
		vim.cmd("wincmd =")
	end,
	desc = "Equalize window splits after terminal resize",
})
