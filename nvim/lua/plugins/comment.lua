-- Comment functionality (replaces tcomment_vim)
return {
	"numToStr/Comment.nvim",
	keys = {
		{ "gc", mode = { "n", "v" }, desc = "Comment toggle" },
		{ "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
	},
	config = function()
		require("Comment").setup({
			-- Use the same keymaps as tcomment_vim
			mappings = {
				basic = true,
				extra = false,
			},
			toggler = {
				line = "gcc",
				block = "gbc",
			},
			opleader = {
				line = "gc",
				block = "gb",
			},
		})
	end,
}

