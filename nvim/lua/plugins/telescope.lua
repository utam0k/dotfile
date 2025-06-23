-- Telescope configuration
return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- vim-bookmarks removed in favor of marks.nvim
			{
				"danielfalk/smart-open.nvim",
				dependencies = { "kkharji/sqlite.lua" },
			},
		},
		cmd = "Telescope",
		keys = {
			{ "<C-p>", "<cmd>Telescope smart_open<cr>", desc = "Smart open" },
			{
				"<C-g>",
				function()
					require("telescope.builtin").live_grep({
						no_ignore = false,
						hidden = true,
					})
				end,
				desc = "Live grep",
			},
			{ "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Go to definition" },
			{ "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
			{ "gi", "<cmd>Telescope lsp_implementations<cr>", desc = "Implementations" },
			{ "<leader>D", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Type definition" },
			{ "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
			{ "<leader>ws", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace symbols" },
			{
				"di",
				function()
					require("telescope.builtin").diagnostics({
						bufnr = 0,
						severity_limit = vim.diagnostic.severity.HINT,
					})
				end,
				desc = "Buffer diagnostics",
			},
			{ "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Find marks" },
			{
				"<leader>gd",
				function()
					require("telescope._extensions.git_hunks").git_hunks()
				end,
				desc = "Git hunks (jump to changes)",
			},
			{
				"<leader>gD",
				function()
					require("telescope._extensions.git_hunks").search_git_diffs()
				end,
				desc = "Search in git diffs",
			},
			{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
			{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					sorting_strategy = "ascending",
					winblend = 4,
					layout_strategy = "vertical",
					layout_config = { height = 0.9 },
					file_ignore_patterns = {
						"^.git/",
						"^node_modules/",
					},
					preview = {
						treesitter = false,
					},
				},
			})
			-- vim_bookmarks extension removed
			telescope.load_extension("smart_open")
			-- Load aerial extension if available
			pcall(telescope.load_extension, "aerial")
		end,
	},
}
