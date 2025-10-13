-- Cargo.toml helper UI
return {
  "saecki/crates.nvim",
  version = "v0.4.0",
  ft = { "toml" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local crates = require("crates")
    crates.setup({
      smart_insert = true,
      insert_closing_quote = true,
      completion = {
        cmp = { enabled = true },
      },
      popup = {
        border = "rounded",
      },
    })

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      pattern = "Cargo.toml",
      callback = function(args)
        local bufnr = args.buf
        local function bufmap(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end

        bufmap("<leader>rc", crates.show_versions_popup, "Crates: Show versions")
        bufmap("<leader>rd", crates.show_dependencies_popup, "Crates: Show dependencies")
        bufmap("<leader>ru", crates.update_crate, "Crates: Update crate")
        bufmap("<leader>rU", crates.update_all_crates, "Crates: Update all crates")
        bufmap("<leader>rD", crates.open_documentation, "Crates: Open docs")
      end,
    })
  end,
}
