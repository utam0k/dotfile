-- Optimized miscellaneous plugins with proper lazy loading
return {
  -- Fix cursor hold - already optimized with VeryLazy
  {
    "antoinemadec/FixCursorHold.nvim",
    event = "VeryLazy",
    config = function()
      -- Fix CursorHold performance issue
      vim.g.cursorhold_updatetime = 100
    end,
  },
  
  -- Schema store for JSON/YAML - load only when needed
  {
    "b0o/schemastore.nvim",
    lazy = true,
    ft = { "json", "jsonc", "yaml" },
  },
  
  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup({
        toggler = {
          line = "co",
          block = "cO",
        },
        opleader = {
          line = "co",
          block = "cO",
        },
      })
    end,
  },
}
