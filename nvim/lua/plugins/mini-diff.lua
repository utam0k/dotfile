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
    local function sync_overlay(buf)
      local mini = require("mini.diff")
      local desired = vim.g.minidiff_overlay_all
      if desired == nil then
        return
      end

      local data = mini.get_buf_data(buf)
      if not data then
        return
      end

      if data.overlay ~= desired then
        mini.toggle_overlay(buf)
      end
    end

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
      vim.g.minidiff_overlay_all = target_state
      for _, item in ipairs(targets) do
        if item.overlay ~= target_state then
          mini.toggle_overlay(item.buf)
        end
      end
    end, { desc = "Toggle git diff overlay (all buffers)" })

    local augroup = vim.api.nvim_create_augroup("MiniDiffOverlayAll", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "BufNewFile" }, {
      group = augroup,
      callback = function(args)
        vim.schedule(function()
          sync_overlay(args.buf)
        end)
      end,
      desc = "Sync mini.diff overlay with global toggle",
    })
  end,
}
