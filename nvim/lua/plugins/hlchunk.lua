-- Highlight chunks
return {
  "shellRaining/hlchunk.nvim",
  event = "VeryLazy",
  config = function()
    require("hlchunk").setup({})
  end,
}
