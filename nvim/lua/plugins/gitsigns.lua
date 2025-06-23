-- Git signs in the gutter
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Keep line highlighting disabled for normal mode
			word_diff = false, -- Keep word diff disabled for normal mode
			current_line_blame = false, -- Disable blame display by default
			-- Enhanced preview settings
			preview_config = {
				border = "rounded",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
			-- Lazy load on first git buffer
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				-- Navigation mappings
				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Use ]g and [g for navigation (handled by mini.diff)
				-- Keep gitsigns for preview and blame
				map("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Toggle git blame" })
				map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
				map("n", "<leader>gD", function()
					gs.diffthis("~")
				end, { desc = "Diff this ~" })

				-- Toggle enhanced diff features when needed
				map("n", "<leader>gw", gs.toggle_word_diff, { desc = "Toggle word diff" })
				map("n", "<leader>gl", gs.toggle_linehl, { desc = "Toggle line highlight" })
			end,
		})
	end,
}
