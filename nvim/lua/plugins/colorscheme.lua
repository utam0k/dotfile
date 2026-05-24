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
		lazy = true,
	},
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
	-- Active colorscheme: Ayu Dark (Zed-inspired)
	{
		"Shatur/neovim-ayu",
		lazy = false,
		priority = 1000,
		config = function()
			require("ayu").setup({
				mirage = false,
				terminal = true,
			})
			vim.cmd.colorscheme("ayu-dark")

			-- NvimTree highlights tuned for Ayu Dark
			local hl_groups = {
				NvimTreeNormal = { bg = "#080a0f" },
				NvimTreeNormalNC = { bg = "#080a0f" },
				NvimTreeCursorLine = { bg = "#11151c" },
				NvimTreeIndentMarker = { fg = "#1d2129" },
				NvimTreeRootFolder = { fg = "#d2a6ff", bold = true },
				NvimTreeFolderName = { fg = "#59c2ff", bold = true },
				NvimTreeOpenedFolderName = { fg = "#59c2ff", bold = true },
				NvimTreeEmptyFolderName = { fg = "#6c7380" },
				NvimTreeFolderArrowClosed = { fg = "#6c7380" },
				NvimTreeFolderArrowOpen = { fg = "#6c7380" },
				NvimTreeOpenedFile = { fg = "#ffb454", bold = true },
				NvimTreeSpecialFile = { fg = "#f29668", italic = true },
				NvimTreeSymlink = { fg = "#39bae6", italic = true },
				NvimTreeGitDirty = { fg = "#ffb454" },
				NvimTreeGitNew = { fg = "#aad94c" },
				NvimTreeGitStaged = { fg = "#aad94c" },
				NvimTreeGitRenamed = { fg = "#39bae6" },
				NvimTreeGitDeleted = { fg = "#d95757" },
				NvimTreeGitMerge = { fg = "#f07178" },
				NvimTreeGitIgnored = { fg = "#4d5566" },
			}
			for name, attrs in pairs(hl_groups) do
				vim.api.nvim_set_hl(0, name, attrs)
			end
		end,
	},
}
