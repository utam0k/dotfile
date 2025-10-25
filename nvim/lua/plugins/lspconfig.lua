-- LSP configuration
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "williamboman/mason.nvim",
  },
  config = function()
    local lsp_helpers = require("config.lsp_helpers")
    -- Constants
    local BORDER_STYLE = "rounded"

    -- Set up borders for LSP floating windows
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = BORDER_STYLE })
    vim.lsp.handlers["textDocument/signatureHelp"] =
      vim.lsp.with(vim.lsp.handlers.signature_help, { border = BORDER_STYLE })

    -- Diagnostic signs
    local DIAGNOSTIC_SIGNS = {
      [vim.diagnostic.severity.ERROR] = "❗",
      [vim.diagnostic.severity.WARN] = "⚠️",
      [vim.diagnostic.severity.HINT] = "💡",
      [vim.diagnostic.severity.INFO] = "ℹ️",
    }

    -- Diagnostic configuration
    vim.diagnostic.config({
      virtual_text = {
        prefix = "●",
        source = "if_many",
        spacing = 4,
        format = function(diagnostic)
          if diagnostic.source then
            return string.format("[%s] %s", diagnostic.source, diagnostic.message)
          end
          return diagnostic.message
        end,
      },
      float = {
        border = BORDER_STYLE,
        source = "if_many",
        header = "",
        prefix = "",
      },
      signs = {
        text = DIAGNOSTIC_SIGNS,
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- Show diagnostics on hover
    vim.api.nvim_create_autocmd("CursorHold", {
      callback = function()
        vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
      end,
    })

    local capabilities = lsp_helpers.make_capabilities()
    local on_attach = lsp_helpers.on_attach

    -- Note: Auto-formatting is handled by conform.nvim to avoid conflicts

    -- Server configurations
    local server_configs = {
      gopls = {
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      },
      terraformls = {
        cmd = { "terraform-ls", "serve" },
      },

      yamlls = {
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/json",
            },
          },
        },
      },

      lua_ls = {
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = {
                vim.fn.expand("$VIMRUNTIME/lua"),
                vim.fn.stdpath("config") .. "/lua",
              },
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      },

      pyright = {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
            },
          },
        },
      },

      clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders=true",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      },

      ts_ls = {},

      -- Additional servers can be added here:
      -- marksman = { filetypes = { "markdown", "markdown.mdx" } },
    }

    -- Determine which LSP configuration API is available
    local function is_callable(fn)
      if vim.is_callable then
        return vim.is_callable(fn)
      end
      if type(fn) == "function" then
        return true
      end
      local mt = getmetatable(fn)
      return mt and type(mt.__call) == "function"
    end

    local use_vim_lsp_config = vim.lsp and vim.lsp.config and is_callable(vim.lsp.config) and is_callable(vim.lsp.enable)

    if use_vim_lsp_config then
      for server_name, config in pairs(server_configs) do
        local existing_on_attach = config.on_attach
        config.on_attach = function(client, bufnr)
          if existing_on_attach then
            existing_on_attach(client, bufnr)
          end
          on_attach(client, bufnr)
        end

        config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})

        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end
    else
      -- Fallback for Neovim versions without vim.lsp.config
      local lspconfig = require("lspconfig")

      for server_name, config in pairs(server_configs) do
        config.on_attach = on_attach
        config.capabilities = capabilities

        if lspconfig[server_name] then
          lspconfig[server_name].setup(config)
        end
      end
    end

    -- Force synchronous parsing for Treesitter
    vim.g._ts_force_sync_parsing = true
  end,
}
