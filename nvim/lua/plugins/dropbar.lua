-- Winbar breadcrumbs
return {
  "Bekaboo/dropbar.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("dropbar").setup()

    local ok, dropbar_api = pcall(require, "dropbar.api")
    if not ok then
      return
    end

    if type(dropbar_api.pick) == "function" then
      vim.keymap.set("n", "<leader>;", dropbar_api.pick, { desc = "Dropbar: Pick symbols in winbar" })
    end
    if type(dropbar_api.goto_context_start) == "function" then
      vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Dropbar: Go to context start" })
    end
    if type(dropbar_api.select_next_context) == "function" then
      vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Dropbar: Select next context" })
    end
  end,
}
