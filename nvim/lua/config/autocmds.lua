-- Autocommands
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Create augroup
local general = augroup("General", { clear = true })

-- Go specific settings
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
  group = general,
})

-- Open quickfix window after grep
autocmd("QuickFixCmdPost", {
  pattern = "*grep*",
  command = "cwindow",
  group = general,
})

-- Cursorline only in current window
autocmd({ "WinLeave" }, {
  callback = function()
    vim.opt_local.cursorline = false
  end,
  group = general,
})

autocmd({ "WinEnter", "BufRead" }, {
  callback = function()
    vim.opt_local.cursorline = true
  end,
  group = general,
})