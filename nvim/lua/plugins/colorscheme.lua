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
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
  },
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "darker",
      })
      vim.o.background = "dark"
      vim.cmd.colorscheme("onedark")

      -- Custom diff highlights for better visibility
      local diff_highlights = {
        { "DiffAdd", { guifg = "#7fa563", guibg = "#2a3429" } },
        { "DiffChange", { guifg = "#f3be7c", guibg = "#3a362a" } },
        { "DiffDelete", { guifg = "#d8647e", guibg = "#3a2a2a" } },
        { "DiffText", { guifg = "#000000", guibg = "#ffff77", gui = "bold" } },
        { "diffAdded", { guifg = "#7fa563", guibg = "NONE" } },
        { "diffRemoved", { guifg = "#d8647e", guibg = "NONE" } },
        { "diffChanged", { guifg = "#f3be7c", guibg = "NONE" } },
        -- mini.diff
        { "MiniDiffOverAdd", { guibg = "#1f3a2e", blend = 25 } },
        { "MiniDiffOverDelete", { guibg = "#3a1f24", blend = 25 } },
        { "MiniDiffOverChange", { guibg = "#3a3320", blend = 25 } },
        { "MiniDiffOverChangeBuf", { guibg = "#3a3320", blend = 25 } },
        { "MiniDiffOverContext", { guibg = "NONE" } },
        { "MiniDiffOverContextBuf", { guibg = "NONE" } },
        -- GitSigns
        { "GitSignsAddLn", { guibg = "#1a2e1a", gui = "NONE" } },
        { "GitSignsChangeLn", { guibg = "#2e2a1a", gui = "NONE" } },
        { "GitSignsDeleteLn", { guibg = "#2e1a1a", gui = "NONE" } },
        { "GitSignsAddWord", { guifg = "#ffffff", guibg = "#4a6e4a", gui = "bold" } },
        { "GitSignsChangeWord", { guifg = "#ffffff", guibg = "#6e5a4a", gui = "bold" } },
        { "GitSignsDeleteWord", { guifg = "#ffffff", guibg = "#6e4a4a", gui = "bold" } },
        -- DiffView
        { "DiffviewDiffAdd", { guifg = "#b8db87", guibg = "#3a4332" } },
        { "DiffviewDiffDelete", { guifg = "#e85a84", guibg = "#4a3238" } },
        { "DiffviewDiffChange", { guifg = "#e0af68", guibg = "#4a3f2d" } },
        { "DiffviewDiffText", { guifg = "#ffffff", guibg = "#6a5f4d", gui = "bold" } },
        { "DiffviewFilePanelTitle", { guifg = "#7aa2f7", gui = "bold" } },
        { "DiffviewFilePanelCounter", { guifg = "#9ece6a" } },
        { "DiffviewFilePanelFileName", { guifg = "#c0caf5" } },
        { "DiffviewFolderName", { guifg = "#7aa2f7" } },
        { "DiffviewFolderSign", { guifg = "#73daca" } },
      }

      -- Fyler (file tree) highlights for a Zed-like sidebar
      local fyler_highlights = {
        { "FylerNormal", { guibg = "#15151f" } },
        { "FylerNormalNC", { guibg = "#15151f" } },
        { "FylerCursorLine", { guibg = "#1d1d2a" } },
        { "FylerIndentMarker", { guifg = "#262638" } },
        { "FylerBorder", { guifg = "#2a2a38", guibg = "#15151f" } },
        -- NvimTree
        { "NvimTreeIndentMarker", { guifg = "#262638" } },
        { "NvimTreeNormal", { guibg = "#15151f" } },
        { "NvimTreeNormalNC", { guibg = "#15151f" } },
        { "NvimTreeCursorLine", { guibg = "#1d1d2a" } },
      }

      -- Custom diagnostic highlights for better visibility
      local diagnostic_highlights = {
        { "DiagnosticError", { guifg = "#ff5555", gui = "bold" } },
        { "DiagnosticWarn", { guifg = "#ffb86c", gui = "bold" } },
        { "DiagnosticInfo", { guifg = "#8be9fd" } },
        { "DiagnosticHint", { guifg = "#50fa7b" } },
        { "DiagnosticVirtualTextError", { guifg = "#ff5555", guibg = "#3a2a2a", gui = "bold" } },
        { "DiagnosticVirtualTextWarn", { guifg = "#ffb86c", guibg = "#3a3229", gui = "bold" } },
        { "DiagnosticVirtualTextInfo", { guifg = "#8be9fd", guibg = "#2a3239" } },
        { "DiagnosticVirtualTextHint", { guifg = "#50fa7b", guibg = "#2a3a2a" } },
        { "DiagnosticLineNrError", { guifg = "#ff5555", guibg = "#4a2a2a", gui = "bold" } },
        { "DiagnosticLineNrWarn", { guifg = "#ffb86c", guibg = "#4a3a29", gui = "bold" } },
        { "DiagnosticLineNrInfo", { guifg = "#8be9fd", guibg = "#2a3a4a" } },
        { "DiagnosticLineNrHint", { guifg = "#50fa7b", guibg = "#2a4a2a" } },
        { "DiagnosticSignError", { guifg = "#ff5555", gui = "bold" } },
        { "DiagnosticSignWarn", { guifg = "#ffb86c", gui = "bold" } },
        { "DiagnosticSignInfo", { guifg = "#8be9fd" } },
        { "DiagnosticSignHint", { guifg = "#50fa7b" } },
        { "DiagnosticUnderlineError", { gui = "undercurl", guisp = "#ff5555" } },
        { "DiagnosticUnderlineWarn", { gui = "undercurl", guisp = "#ffb86c" } },
        { "DiagnosticUnderlineInfo", { gui = "undercurl", guisp = "#8be9fd" } },
        { "DiagnosticUnderlineHint", { gui = "undercurl", guisp = "#50fa7b" } },
      }

      -- Apply highlights
      local function apply_highlights(highlights)
        for _, hl in ipairs(highlights) do
          local name, attrs = hl[1], hl[2]
          local cmd = "highlight " .. name
          if attrs.guifg then
            cmd = cmd .. " guifg=" .. attrs.guifg
          end
          if attrs.guibg then
            cmd = cmd .. " guibg=" .. attrs.guibg
          end
          if attrs.gui then
            cmd = cmd .. " gui=" .. attrs.gui
          end
          if attrs.guisp then
            cmd = cmd .. " guisp=" .. attrs.guisp
          end
          if attrs.blend then
            cmd = cmd .. " blend=" .. attrs.blend
          end
          vim.cmd(cmd)
        end
      end

      apply_highlights(diff_highlights)
      apply_highlights(fyler_highlights)
      apply_highlights(diagnostic_highlights)
    end,
  },
  -- Keep vague available as an optional theme
  {
    "vague2k/vague.nvim",
    lazy = true,
    config = function()
      require("vague").setup({
        colors = {
          bg = "#1a1a24",
        },
      })
    end,
  },
}
