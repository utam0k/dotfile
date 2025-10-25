-- File tree explorer (alternative to oil.nvim)
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    "s1n7ax/nvim-window-picker",
  },
  cmd = "Neotree",
  keys = {
    { "<Space>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
    { "<Space>g", "<cmd>Neotree git_status toggle<cr>", desc = "Neo-tree Git status" },
    { "<Space>b", "<cmd>Neotree buffers toggle<cr>", desc = "Neo-tree Buffers" },
  },
  config = function()
    require("neo-tree").setup({
      filesystem = {
        filtered_items = {
          visible = true, -- 隠しファイルを表示
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    })
  end,
}
