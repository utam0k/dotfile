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
    view = {
        width = "12%",
        -- float = {
        --     enable = true,
        -- },
    },
}
vim.keymap.set("n", "<SPACE>e", "<CMD>NvimTreeToggle<CR>")
