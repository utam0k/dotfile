-- Enhanced marks management (replaces vim-bookmarks)
return {
	"chentoast/marks.nvim",
	event = "VeryLazy",
	config = function()
		require("marks").setup({
			default_mappings = false,
			builtin_marks = { ".", "<", ">", "^" },
			cyclic = true,
			force_write_shada = false,
			refresh_interval = 250,
			sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
			excluded_filetypes = { "neo-tree", "oil" },
			bookmark_0 = {
				sign = "",
				virt_text = "bookmark",
				annotate = false,
			},
			mappings = {
				toggle = "mm", -- Toggle mark at cursor
				next = "mn", -- Go to next mark
				prev = "mp", -- Go to previous mark
				preview = "m:", -- Preview mark
				set_next = "m,", -- Set next available lowercase mark
				delete_line = "dm", -- Delete all marks on line
				delete_buf = "dm-", -- Delete all marks in buffer
				next_bookmark = "m]", -- Go to next bookmark
				prev_bookmark = "m[", -- Go to previous bookmark
				annotate = "mi", -- Annotate mark
			},
		})

		-- Additional keymaps for compatibility with vim-bookmarks
		vim.keymap.set("n", "<leader>ma", "<cmd>MarksListAll<cr>", { desc = "List all marks" })
		vim.keymap.set("n", "<leader>mb", "<cmd>MarksListBuf<cr>", { desc = "List buffer marks" })
	end,
}

