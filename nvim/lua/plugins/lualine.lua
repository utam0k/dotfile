-- Status line configuration (currently disabled in favor of incline.nvim)
return {
	"nvim-lualine/lualine.nvim",
	enabled = false, -- Disabled in favor of incline.nvim
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"SmiteshP/nvim-navic",
	},
	event = "VeryLazy",
	config = function()
		local lualine = require("lualine")
		local navic = require("nvim-navic")

		-- Custom components
		local custom_filename = function()
			local filetype = vim.bo.filetype
			if filetype == "neo-tree" then
				return "Neo-tree"
			elseif filetype == "oil" then
				return "Oil"
			else
				local filename = vim.fn.expand("%:.")
				if filename == "" then
					filename = "[No Name]"
				end

				local modified = vim.bo.modified and " +" or ""
				local readonly = vim.bo.readonly and " !" or ""

				return readonly .. filename .. modified
			end
		end

		local custom_branch = function()
			local filetype = vim.bo.filetype
			if filetype == "help" or filetype == "neo-tree" or filetype == "oil" then
				return ""
			end

			local branch = vim.fn["fugitive#head"]()
			return branch ~= "" and " " .. branch or ""
		end

		local custom_navic = function()
			local filetype = vim.bo.filetype
			if filetype == "help" or filetype == "neo-tree" or filetype == "oil" then
				return ""
			end

			if navic.is_available() then
				return navic.get_location()
			else
				return ""
			end
		end

		-- Custom component for search match count
		local search_count = function()
			if vim.v.hlsearch == 0 then
				return ""
			end

			local ok, result = pcall(vim.fn.searchcount, { timeout = 100 })
			if not ok or result.total == 0 then
				return ""
			end

			if result.incomplete == 1 then
				return " ?/?"
			elseif result.total > result.maxcount then
				return string.format(" %d/>%d", result.current, result.maxcount)
			else
				return string.format(" %d/%d", result.current, result.total)
			end
		end

		-- Custom component for total line count
		local line_count = function()
			local lines = vim.api.nvim_buf_line_count(0)
			return " " .. lines
		end

		lualine.setup({
			options = {
				theme = "auto", -- Automatically detect from colorscheme
				icons_enabled = true,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				always_divide_middle = true,
				globalstatus = false,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { custom_branch, "diff", "diagnostics" },
				lualine_c = { custom_filename, custom_navic },
				lualine_x = { search_count, line_count, "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { custom_filename },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = { "neo-tree", "fugitive" },
		})
	end,
}

