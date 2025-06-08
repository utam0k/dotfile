-- Search and replace
return {
  "dyng/ctrlsf.vim",
  cmd = { "CtrlSF", "CtrlSFOpen" },
  keys = {
    { "<leader>sf", ":CtrlSF ", desc = "Search with CtrlSF" },
  },
}