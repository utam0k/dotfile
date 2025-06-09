-- LSP configuration
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "williamboman/mason.nvim",
  },
  config = function()
    -- Set up borders for LSP floating windows
    local border = "rounded"
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })

    -- Diagnostic configuration
    vim.diagnostic.config({
      virtual_text = {
        prefix = "●",
        source = "if_many",
      },
      float = {
        border = border,
        source = "if_many",
        header = "",
        prefix = "",
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "✘",
          [vim.diagnostic.severity.WARN] = "▲",
          [vim.diagnostic.severity.HINT] = "⚡",
          [vim.diagnostic.severity.INFO] = "»",
        },
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

    -- Create capabilities with nvim-cmp
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

    -- Shared on_attach function
    local on_attach = function(client, bufnr)
      -- Buffer local mappings
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- Navigation mappings (handled by telescope.lua for gd/gr)
      map("n", "K", vim.lsp.buf.hover, "LSP: Hover documentation")
      map("n", "<leader>k", vim.lsp.buf.signature_help, "LSP: Signature help")
      map("i", "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature help")

      -- Action mappings
      map("n", "\\rn", vim.lsp.buf.rename, "LSP: Rename symbol")
      map({ "n", "x" }, "\\ca", vim.lsp.buf.code_action, "LSP: Code action")
      -- Note: Formatting is now handled by conform.nvim (\\f mapping in formatting.lua)

      -- Workspace mappings
      map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "LSP: Add workspace folder")
      map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "LSP: Remove workspace folder")
      map("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, "LSP: List workspace folders")

      -- Client-specific settings
      if client.name == "rust_analyzer" then
        -- Disable semantic tokens to avoid flickering
        client.server_capabilities.semanticTokensProvider = nil
      end

      -- Disable LSP formatting in favor of conform.nvim
      -- This prevents conflicts and ensures consistent formatting
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false

      -- Enable inlay hints if supported
      if client.supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end

    -- Note: Auto-formatting is now handled by conform.nvim
    -- The previous LSP-based format on save has been removed to avoid conflicts

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

      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              features = "all",
              loadOutDirsFromCheck = true,
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
          "--function-arg-placeholders",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      },

      ts_ls = {},
      hls = {},
      
      -- Markdown LSP (install via Mason if needed)
      -- marksman = {
      --   filetypes = { "markdown", "markdown.mdx" },
      -- },
    }

    -- Set up each LSP server manually
    local lspconfig = require("lspconfig")

    -- Go through each server config and set it up
    for server_name, config in pairs(server_configs) do
      config.on_attach = on_attach
      config.capabilities = capabilities

      -- Check if the server configuration exists
      if lspconfig[server_name] then
        lspconfig[server_name].setup(config)
      end
    end

    -- Force synchronous parsing for Treesitter (temporary workaround)
    vim.g._ts_force_sync_parsing = true
  end,
}

