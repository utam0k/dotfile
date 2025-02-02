require("window-picker").setup({
    filter_rules = {
      include_current_win = false,
      autoselect_one = true,
      -- filter using buffer options
      bo = {
        -- if the file type is one of following, the window will be ignored
        filetype = { "neo-tree", "neo-tree-popup", "notify" },
        -- if the buffer type is one of following, the window will be ignored
        buftype = { "terminal", "quickfix" },
      },
    },
})

require("neo-tree").setup{
    source_selector = {
        winbar = true,
        statusline = true 
    }
}
vim.keymap.set("n", "<SPACE>e", "<CMD>Neotree filesystem reveal left toggle<CR>")
vim.keymap.set("n", "<SPACE>f", "<CMD>Neotree float toggle<CR>")
