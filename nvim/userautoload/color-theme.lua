-- Lua:
-- -- For dark theme (neovim's default)
-- vim.o.background = 'dark'
--
-- local c = require('vscode.colors').get_colors()
-- require('vscode').setup({
--     -- Alternatively set style in setup
--     -- style = 'light'
--
--     -- Enable transparent background
--     transparent = true,
--
--     -- Enable italic comment
--     italic_comments = true,
--
--     -- Disable nvim-tree background color
--     disable_nvimtree_bg = true,
--
--     -- Override colors (see ./lua/vscode/colors.lua)
--     -- color_overrides = {
--     --     vscLineNumber = '#FFFFFF',
--     -- },
--     --
--     -- -- Override highlight groups (see ./lua/vscode/theme.lua)
--     -- group_overrides = {
--     --     -- this supports the same val table as vim.api.nvim_set_hl
--     --     -- use colors from this colorscheme by requiring vscode.colors!
--     --     Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
--     -- }
-- })
-- require('vscode').load()
--
-- vim.cmd.colorscheme "vscode"
--
-- -- hlchunk
-- require('hlchunk').setup({
--     indent = {
--         enable = true,
--         style = {
--             { fg = c.vscCursorDark},
--         },
--     },
--     chunk = {
--         style = {
--             { fg = c.vscBlue },
--             { fg = c.vscOrange },
--         },
--     },
--     blank = {
--         enable = true,
--         style = {
--             { fg = c.vscCursorDark},
--         },
--     },
--     line_num = {
--         enable = false,
--     }
-- })


require('kanagawa').setup({
  compile      = true,
  theme        = 'wave',              -- dragon / wave / lotus
  dimInactive  = false,               -- true を試すのもアリ
  background   = { dark = 'wave', light = 'lotus' },

  overrides = function(colors)
    local theme = colors.theme
    local palette = colors.palette
    return {
      Visual = { bg = palette.waveBlue2 },
      NormalFloat = { bg = "none" },
      FloatBorder = { bg = "none" },
      Pmenu     = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
      PmenuSel  = { fg = "NONE",         bg = theme.ui.bg_p2 },
      PmenuSbar = { bg = theme.ui.bg_m1 },
      PmenuThumb= { bg = theme.ui.bg_p2 },
      DiagnosticVirtualTextError = { fg = theme.diag.error,
                                     bg = require('kanagawa.lib.color')(
                                           theme.diag.error):blend(theme.ui.bg, 0.93):to_hex() },
    }
  end,
})

vim.cmd.colorscheme 'kanagawa'
