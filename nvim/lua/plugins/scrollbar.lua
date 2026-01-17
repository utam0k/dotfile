-- Scrollbar with git diff indicators
return {
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("gitsigns").setup({
        signcolumn = false,
      })
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    dependencies = { "lewis6991/gitsigns.nvim" },
    config = function()
      require("scrollbar").setup({
        handle = { text = "▎" },
        marks = {
          GitAdd = { text = "▎" },
          GitChange = { text = "▎" },
          GitDelete = { text = "▎" },
        },
      })
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },
}
