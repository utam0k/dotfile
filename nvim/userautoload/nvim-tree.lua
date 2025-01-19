require("nvim-tree").setup{
    diagnostics = {
        enable = true,
    },
    filters = {
        dotfiles = true,
    },
    update_focused_file = {
		enable = true,
		update_cwd = false,
	},
    auto_expand_width = false,
}
vim.keymap.set("n", "<SPACE>e", "<CMD>NvimTreeToggle<CR>")
