-- Telescope configuration
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MattesGroeger/vim-bookmarks",
      "tom-anders/telescope-vim-bookmarks.nvim",
      {
        "danielfalk/smart-open.nvim",
        dependencies = { "kkharji/sqlite.lua" },
      },
    },
    cmd = "Telescope",
    keys = {
      { "<C-p>", "<cmd>Telescope smart_open<cr>", desc = "Smart open" },
      { "<C-g>", function()
          require("telescope.builtin").live_grep({
            no_ignore = false,
            hidden = true
          })
        end, desc = "Live grep" },
      { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Go to definition" },
      { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
      { "gi", "<cmd>Telescope lsp_implementations<cr>", desc = "Implementations" },
      { "<leader>D", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Type definition" },
      { "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>ws", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "di", function()
          require("telescope.builtin").diagnostics({
            bufnr = 0,
            severity_limit = vim.diagnostic.severity.HINT
          })
        end, desc = "Buffer diagnostics" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          sorting_strategy = "ascending",
          winblend = 4,
          layout_strategy = "vertical",
          layout_config = { height = 0.9 },
          file_ignore_patterns = {
            "^.git/",
            "^node_modules/",
          },
          preview = {
            treesitter = false,
          },
        },
      })
      telescope.load_extension("vim_bookmarks")
      telescope.load_extension("smart_open")
    end,
  },
}