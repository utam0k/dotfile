-- Colorscheme plugins
return {
  -- Keep inactive colorschemes lazy
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
  },
  {
    "Mofiqul/vscode.nvim",
    lazy = true,
  },
  -- Kanagawa is loaded as a dependency of vague, so keep it lazy
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    config = function()
      require("kanagawa").setup({
        compile = true,
        theme = "wave",
        dimInactive = false,
        background = { dark = "wave", light = "lotus" },
        overrides = function(colors)
          local theme = colors.theme
          local palette = colors.palette
          return {
            Visual = { bg = palette.waveBlue2 },
            NormalFloat = { bg = "none" },
            FloatBorder = { bg = "none" },
            Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
            PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },
            DiagnosticVirtualTextError = {
              fg = theme.diag.error,
              bg = require("kanagawa.lib.color")(theme.diag.error):blend(theme.ui.bg, 0.93):to_hex(),
            },
          }
        end,
      })
    end,
  },
  -- Main colorscheme (vague) - load with high priority
  {
    "vague2k/vague.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { "rebelot/kanagawa.nvim" },
    config = function()
      -- Setup kanagawa first (since vague depends on it being loaded)
      require("kanagawa").setup({
        compile = true,
        theme = "wave",
        dimInactive = false,
        background = { dark = "wave", light = "lotus" },
        overrides = function(colors)
          local theme = colors.theme
          local palette = colors.palette
          return {
            Visual = { bg = palette.waveBlue2 },
            NormalFloat = { bg = "none" },
            FloatBorder = { bg = "none" },
            Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
            PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },
            DiagnosticVirtualTextError = {
              fg = theme.diag.error,
              bg = require("kanagawa.lib.color")(theme.diag.error):blend(theme.ui.bg, 0.93):to_hex(),
            },
          }
        end,
      })

      -- Setup vague
      require("vague").setup({})
      vim.o.background = "dark"
      vim.cmd.colorscheme("kanagawa") -- For some reason, vague must be set after something else
      vim.cmd.colorscheme("vague")

      -- Fix diff colors for better visibility with vague colorscheme
      -- These settings make diff colors more visible in vimdiff and git operations
      vim.cmd([[
        highlight DiffAdd guifg=#7fa563 guibg=#2a3429
        highlight DiffChange guifg=#f3be7c guibg=#3a362a
        highlight DiffDelete guifg=#d8647e guibg=#3a2a2a
        highlight DiffText guifg=#cdcdcd guibg=#4a4a2a gui=bold
        
        " For Neovim-specific diff highlighting (used in some plugins)
        highlight diffAdded guifg=#7fa563 guibg=NONE
        highlight diffRemoved guifg=#d8647e guibg=NONE
        highlight diffChanged guifg=#f3be7c guibg=NONE
      ]])
    end,
  },
}
