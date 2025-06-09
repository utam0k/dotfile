-- Git signs in the gutter
return {
  "lewis6991/gitsigns.nvim",
  event = "VeryLazy",
  cond = function()
    -- Only load in git repositories
    return vim.fn.isdirectory(vim.fn.getcwd() .. "/.git") == 1
  end,
  config = function()
    require("gitsigns").setup({
      current_line_blame = true,
      -- Lazy load on first git buffer
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        
        -- Navigation mappings
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true, desc = "Next git hunk"})
        
        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true, desc = "Previous git hunk"})
      end,
    })
  end,
}
