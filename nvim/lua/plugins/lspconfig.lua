-- LSP configuration
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    
    -- LSP on_attach function
    local on_attach = function(client, bufnr)
      if client.name == "rust_analyzer" then
        -- For avoiding flickering
        client.server_capabilities.semanticTokensProvider = nil
      end
      
      -- Auto format for Go and Rust
      if client.name == "gopls" or client.name == "rust_analyzer" then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end
      
      -- Keymaps
      local opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set("n", "\\rn", vim.lsp.buf.rename, vim.tbl_extend("error", opts, { desc = "LSP: rename symbol" }))
      vim.keymap.set({ "x", "n" }, "\\ca", vim.lsp.buf.code_action, vim.tbl_extend("error", opts, { desc = "LSP: code action" }))
    end
    
    -- Server configurations
    lspconfig.gopls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        gopls = {
          completeUnimported = true,
        },
      },
    })
    
    lspconfig.rust_analyzer.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true, features = "all" },
          check = {
            command = "clippy",
            overrideCommand = {
              "cargo", "clippy", "--message-format=json",
              "--all-targets", "--all-features", "--", "-Dwarnings",
            },
          },
        },
      },
    })
    
    lspconfig.terraformls.setup({
      cmd = { "terraform-ls", "serve" },
      on_attach = on_attach,
      capabilities = capabilities,
    })
    
    lspconfig.yamlls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
    
    -- Other language servers
    for _, server in ipairs({ "lua_ls", "clangd", "pyright", "ts_ls", "hls" }) do
      lspconfig[server].setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end
    
    -- Diagnostics configuration
    vim.diagnostic.config({
      virtual_text = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })
    
    -- Show diagnostics on hover
    vim.api.nvim_create_autocmd("CursorHold", {
      callback = function()
        vim.diagnostic.open_float(nil, {
          focus = false,
          border = "rounded",
          scope = "cursor",
          source = "if_many",
        })
      end,
    })
    
    -- TODO: Remove this line when nvim reaches 0.11.2
    vim.g._ts_force_sync_parsing = true
  end,
}