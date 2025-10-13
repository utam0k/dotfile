-- Automatic installation of formatters and linters via Mason
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "williamboman/mason.nvim",
  },
  cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
  event = { "VeryLazy" },
  config = function()
    require("mason-tool-installer").setup({
      ensure_installed = {
        -- Formatters only (LSP handles diagnostics/linting)
        "goimports",
        "gofumpt",
        "ruff",
        "prettier",
        "stylua",
        "shfmt",
        "delve",
        "codelldb",
        "rust-analyzer",
      },
      
      -- Auto update on startup
      auto_update = false,
      
      -- Run on startup (disabled to avoid errors)
      run_on_start = false,
      
      -- Delay before installing on startup
      start_delay = 3000, -- 3 seconds
      
      -- Debounce for tool installations
      debounce_hours = 5, -- at least 5 hours between auto-install runs
    })
  end,
}
