-- Namu.nvim - jump to symbols with live preview
return {
  "bassamsdata/namu.nvim",
  cmd = "Namu",
  keys = {
    { "<Space>s", "<cmd>Namu symbols<cr>", desc = "Symbols (Namu)" },
    { "<leader>ss", "<cmd>Namu symbols<cr>", desc = "Symbols (Namu)" },
    { "<leader>sw", "<cmd>Namu workspace<cr>", desc = "Workspace symbols (Namu)" },
  },
  opts = {},
}
