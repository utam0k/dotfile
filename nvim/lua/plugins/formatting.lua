-- Formatting configuration using conform.nvim
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "\\f",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    -- Define formatters per filetype
    formatters_by_ft = {
      -- Go
      -- go = { "goimports", "gofumpt" },

      -- Rust
      rust = { "rustfmt" },

      -- Python
      python = { "ruff_format", "ruff_fix" },

      -- JavaScript/TypeScript
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },

      -- Web formats
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },

      -- Lua
      lua = { "stylua" },

      -- YAML
      yaml = { "prettier" },

      -- Markdown
      markdown = { "prettier" },
      ["markdown.mdx"] = { "prettier" },

      -- Shell scripts
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },

      -- TOML
      toml = { "taplo" },

      -- Terraform
      terraform = { "terraform_fmt" },
      tf = { "terraform_fmt" },
      ["terraform-vars"] = { "terraform_fmt" },

      -- C/C++
      c = { "clang_format" },
      cpp = { "clang_format" },

      -- Use LSP formatter for these filetypes
      ["_"] = { "trim_whitespace" },
    },

    -- Format on save configuration
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

      -- Disable for certain filetypes
      local disable_filetypes = { "sql", "java" }
      if vim.tbl_contains(disable_filetypes, vim.bo[bufnr].filetype) then
        return
      end

      return {
        timeout_ms = 500,
        lsp_fallback = true,
        async = false,
      }
    end,

    -- Configure formatters
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2", "-ci" }, -- 2 space indent, indent case labels
      },
      stylua = {
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
      },
      prettier = {
        prepend_args = { "--tab-width", "2" },
      },
      ruff_format = {
        prepend_args = { "--line-length", "88" },
      },
      ruff_fix = {
        prepend_args = { "--select", "I", "--fix" }, -- Sort imports
      },
    },
  },
  init = function()
    -- Create user commands for toggling autoformat
    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, {
      desc = "Disable autoformat on save",
      bang = true,
    })

    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = "Re-enable autoformat on save",
    })

    -- Show formatter info
    vim.api.nvim_create_user_command("FormatInfo", function()
      vim.cmd("ConformInfo")
    end, {
      desc = "Show formatter info for current buffer",
    })
  end,
}
