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
      local mini = require("mini.diff")
      local targets = {}
      local any_off = false

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local data = mini.get_buf_data(buf)
        if data then
          table.insert(targets, { buf = buf, overlay = data.overlay })
          if not data.overlay then
            any_off = true
          end
        end
      end

      if #targets == 0 then
        return
      end

      local target_state = any_off
      for _, item in ipairs(targets) do
        if item.overlay ~= target_state then
          mini.toggle_overlay(item.buf)
        end
      end
    end, { desc = "Toggle git diff overlay (all buffers)" })
  end,
}
