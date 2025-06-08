-- Git diff viewer
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles" },
  config = function()
    require("diffview").setup({})
  end,
}