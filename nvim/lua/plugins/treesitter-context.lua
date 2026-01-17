-- Sticky context at the top of the window
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("treesitter-context").setup({
      mode = "cursor",
      max_lines = 3,
      trim_scope = "outer",
    })

    vim.keymap.set("n", "<leader>tc", function()
      require("treesitter-context").toggle()
    end, { desc = "TSContext: Toggle" })
  end,
}
