-- Flash for quick navigation
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    -- Enable flash for search
    search = {
      enabled = true,
      highlight = {
        backdrop = false,
      },
      jump = {
        history = true,
        register = true,
        nohlsearch = true,
      },
      exclude = {
        "cmp_menu",
        "flash_prompt",
        function(win)
          -- Exclude non-focusable windows
          return not vim.api.nvim_win_get_config(win).focusable
        end,
      },
    },
    -- Flash when searching with / ? * # g* g#
    modes = {
      search = {
        enabled = true,
        highlight = { backdrop = false },
        jump = { history = true, register = true, nohlsearch = true },
      },
      char = {
        enabled = true,
        -- Hide after jump when not using jump labels
        autohide = false,
        jump_labels = true,
        multi_line = false,
      },
    },
    label = {
      uppercase = false,
      rainbow = {
        enabled = true,
        shade = 5,
      },
    },
  },
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
