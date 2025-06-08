-- Highlight chunks
return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("hlchunk").setup({})
  end,
}