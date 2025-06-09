-- Mason configuration for LSP server management
return {
  "williamboman/mason.nvim",
  build = ":MasonUpdate",
  cmd = "Mason",
  lazy = false,
  priority = 100,
  config = function()
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    })
  end,
}
