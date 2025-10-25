-- Enhanced Rust tooling via rustaceanvim
return {
  "mrcjkb/rustaceanvim",
  version = "^4",
  ft = { "rust" },
  dependencies = {
    "mfussenegger/nvim-dap",
    "williamboman/mason.nvim",
  },
  init = function()
    local helpers = require("config.lsp_helpers")

    local function get_codelldb_adapter()
      local helpers = require("config.codelldb")
      local paths = helpers.get_paths()
      if not paths then
        vim.notify("Failed to resolve codelldb install path.", vim.log.levels.ERROR)
        return nil
      end

      local cfg = require("rustaceanvim.config")
      return cfg.get_codelldb_adapter(paths.codelldb, paths.liblldb)
    end

    vim.g.rustaceanvim = {
      tools = {
        hover_actions = {
          auto_focus = true,
        },
        executor = require("rustaceanvim.executors").termopen,
      },
      server = {
        on_attach = helpers.on_attach,
        capabilities = helpers.make_capabilities(),
        default_settings = {
          ["rust-analyzer"] = {
            allFeatures = true,
            cargo = {
              allFeatures = true,
              features = "all",
              loadOutDirsFromCheck = true,
              buildScripts = { enable = true },
            },
            check = {
              command = "clippy",
              overrideCommand = {
                "cargo",
                "clippy",
                "--message-format=json",
                "--all-targets",
                "--all-features",
                "--",
                "-Dwarnings",
              },
            },
            procMacro = {
              enable = true,
            },
            diagnostics = {
              experimental = {
                enable = true,
              },
            },
          },
        },
      },
      dap = {
        adapter = get_codelldb_adapter,
      },
    }
  end,
}
