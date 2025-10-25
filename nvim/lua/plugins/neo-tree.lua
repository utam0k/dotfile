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
    { "<Space>g", "<cmd>Neotree git_status toggle<cr>", desc = "Neo-tree Git status" },
    { "<Space>b", "<cmd>Neotree buffers toggle<cr>", desc = "Neo-tree Buffers" },
  },
  config = function()
    require("neo-tree").setup({
      sources = { "buffers", "git_status" },
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
        },
        git_status = {
          symbols = {
            added = " ",
            modified = " ",
            deleted = " ",
            renamed = " ",
            untracked = " ",
            ignored = " ",
            unstaged = " ",
            staged = " ",
            conflict = " ",
          },
        },
      },
      window = {
        width = math.min(math.floor(vim.o.columns * 0.22), 50),
        mappings = {
          ["<space>"] = "noop",
          ["<C-h>"] = "toggle_hidden",
          ["?"] = "show_help",
        },
      },
      buffers = {
        follow_current_file = true,
        group_empty_dirs = true,
        window = {
          position = "float",
        },
      },
      git_status = {
        window = {
          position = "float",
        },
      },
    })
  end,
}
