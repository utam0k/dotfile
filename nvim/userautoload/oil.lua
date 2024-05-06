require("oil").setup({})
vim.keymap.set("n", "<SPACE>e", "<CMD>Oil<CR>")
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
