-- Highlight chunks
return {
  "shellRaining/hlchunk.nvim",
  event = "VeryLazy",
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
        style = {
          { fg = "#806d9c" },
          { fg = "#c21f30" }, -- エラーチャンクの色
        },
      },
      indent = {
        enable = true,
        style = {
          "#3a3a3a",
        },
      },
      line_num = {
        enable = true,
        style = "#806d9c",
      },
      blank = {
        enable = false,
      },
    })
  end,
}
