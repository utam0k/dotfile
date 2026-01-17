-- Enhanced diff visualization with overlay
return {
  "echasnovski/mini.nvim",
  version = false,
  event = "VeryLazy",
  config = function()
    require("mini.diff").setup({
      -- Use sign style for a thin vertical bar (Zed-like)
      view = {
        style = "sign",
        signs = { add = "▎", change = "▎", delete = "▎" },
        priority = 199, -- Leave room for other sign providers
      },
      -- Diff algorithm options
      options = {
        algorithm = "histogram",
        indent_heuristic = true,
        linematch = 60, -- Enable word-level diff in overlay
      },
      -- Mappings for hunk operations
      mappings = {
        apply = "gh", -- Apply hunk
        reset = "gH", -- Reset hunk
        textobject = "gh", -- Select hunk as text object
        goto_first = "[G", -- Go to first hunk
        goto_last = "]G", -- Go to last hunk
        goto_next = "]g", -- Go to next hunk
        goto_prev = "[g", -- Go to previous hunk
      },
    })

    -- Additional keymaps for overlay
    vim.keymap.set("n", "<leader>go", function()
      require("mini.diff").toggle_overlay()
    end, { desc = "Toggle git diff overlay" })
  end,
}
