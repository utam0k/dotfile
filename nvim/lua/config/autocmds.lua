-- Autocommands
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Create augroup
local general = augroup("General", { clear = true })

-- Open quickfix window automatically after grep commands
autocmd("QuickFixCmdPost", {
  pattern = "*grep*",
  command = "cwindow",
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
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
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
  callback = function()
    vim.api.nvim_echo({ { "File changed on disk. Buffer reloaded.", "WarningMsg" } }, true, {})
  end,
  desc = "Notify when file is reloaded due to external changes",
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
