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
	-- Kanagawa is loaded as a dependency of vague
	{
		"rebelot/kanagawa.nvim",
		lazy = true,
	},
	-- Main colorscheme (vague) - load with high priority
	{
		"vague2k/vague.nvim",
		lazy = false,
		priority = 1000,
		dependencies = { "rebelot/kanagawa.nvim" },
		config = function()
			-- Kanagawa configuration
			local kanagawa_config = {
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
			}

			-- Setup kanagawa first (since vague depends on it being loaded)
			require("kanagawa").setup(kanagawa_config)

			-- Setup vague
			require("vague").setup({})
			vim.o.background = "dark"
			vim.cmd.colorscheme("kanagawa") -- For some reason, vague must be set after something else
			vim.cmd.colorscheme("vague")

			-- Define custom diff highlights for better visibility
			local diff_highlights = {
				-- Standard diff colors
				{ "DiffAdd", { guifg = "#7fa563", guibg = "#2a3429" } },
				{ "DiffChange", { guifg = "#f3be7c", guibg = "#3a362a" } },
				{ "DiffDelete", { guifg = "#d8647e", guibg = "#3a2a2a" } },
				{ "DiffText", { guifg = "#cdcdcd", guibg = "#4a4a2a", gui = "bold" } },

				-- Neovim-specific diff highlighting (used in some plugins)
				{ "diffAdded", { guifg = "#7fa563", guibg = "NONE" } },
				{ "diffRemoved", { guifg = "#d8647e", guibg = "NONE" } },
				{ "diffChanged", { guifg = "#f3be7c", guibg = "NONE" } },

				-- mini.diff overlay highlights
				{ "MiniDiffOverAdd", { guifg = "#e0e0e0", guibg = "#2d4a2b", gui = "NONE" } },
				{ "MiniDiffOverDelete", { guifg = "#e0e0e0", guibg = "#4a2b2b", gui = "NONE" } },
				{ "MiniDiffOverChange", { guifg = "#e0e0e0", guibg = "#4a3c2b", gui = "NONE" } },
				{ "MiniDiffOverContext", { guifg = "#808080", guibg = "#1a1a1a", gui = "italic" } },

				-- Enhanced diff highlighting (only used when toggled on)
				{ "DiffText", { guifg = "#000000", guibg = "#ffff77", gui = "bold" } },
				{ "GitSignsAddLn", { guibg = "#1a2e1a", gui = "NONE" } },
				{ "GitSignsChangeLn", { guibg = "#2e2a1a", gui = "NONE" } },
				{ "GitSignsDeleteLn", { guibg = "#2e1a1a", gui = "NONE" } },
				{ "GitSignsAddWord", { guifg = "#ffffff", guibg = "#4a6e4a", gui = "bold" } },
				{ "GitSignsChangeWord", { guifg = "#ffffff", guibg = "#6e5a4a", gui = "bold" } },
				{ "GitSignsDeleteWord", { guifg = "#ffffff", guibg = "#6e4a4a", gui = "bold" } },

				-- DiffView specific highlighting
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

			-- Apply all diff highlights
			for _, highlight in ipairs(diff_highlights) do
				local name = highlight[1]
				local attrs = highlight[2]
				local cmd = string.format("highlight %s", name)

				if attrs.guifg then
					cmd = cmd .. " guifg=" .. attrs.guifg
				end
				if attrs.guibg then
					cmd = cmd .. " guibg=" .. attrs.guibg
				end
				if attrs.gui then
					cmd = cmd .. " gui=" .. attrs.gui
				end

				vim.cmd(cmd)
			end

			-- Enhanced diagnostic highlights for better visibility
			local diagnostic_highlights = {
				-- Main diagnostic colors
				{ "DiagnosticError", { guifg = "#ff5555", gui = "bold" } },
				{ "DiagnosticWarn", { guifg = "#ffb86c", gui = "bold" } },
				{ "DiagnosticInfo", { guifg = "#8be9fd" } },
				{ "DiagnosticHint", { guifg = "#50fa7b" } },

				-- Virtual text with background colors
				{ "DiagnosticVirtualTextError", { guifg = "#ff5555", guibg = "#3a2a2a", gui = "bold" } },
				{ "DiagnosticVirtualTextWarn", { guifg = "#ffb86c", guibg = "#3a3229", gui = "bold" } },
				{ "DiagnosticVirtualTextInfo", { guifg = "#8be9fd", guibg = "#2a3239" } },
				{ "DiagnosticVirtualTextHint", { guifg = "#50fa7b", guibg = "#2a3a2a" } },

				-- Line number highlighting for errors
				{ "DiagnosticLineNrError", { guifg = "#ff5555", guibg = "#4a2a2a", gui = "bold" } },
				{ "DiagnosticLineNrWarn", { guifg = "#ffb86c", guibg = "#4a3a29", gui = "bold" } },
				{ "DiagnosticLineNrInfo", { guifg = "#8be9fd", guibg = "#2a3a4a" } },
				{ "DiagnosticLineNrHint", { guifg = "#50fa7b", guibg = "#2a4a2a" } },

				-- Sign column
				{ "DiagnosticSignError", { guifg = "#ff5555", gui = "bold" } },
				{ "DiagnosticSignWarn", { guifg = "#ffb86c", gui = "bold" } },
				{ "DiagnosticSignInfo", { guifg = "#8be9fd" } },
				{ "DiagnosticSignHint", { guifg = "#50fa7b" } },

				-- Underline styles
				{ "DiagnosticUnderlineError", { gui = "undercurl", guisp = "#ff5555" } },
				{ "DiagnosticUnderlineWarn", { gui = "undercurl", guisp = "#ffb86c" } },
				{ "DiagnosticUnderlineInfo", { gui = "undercurl", guisp = "#8be9fd" } },
				{ "DiagnosticUnderlineHint", { gui = "undercurl", guisp = "#50fa7b" } },
			}

			-- Apply diagnostic highlights
			for _, highlight in ipairs(diagnostic_highlights) do
				local name = highlight[1]
				local attrs = highlight[2]
				local cmd = string.format("highlight %s", name)

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

				vim.cmd(cmd)
			end
		end,
	},
}
