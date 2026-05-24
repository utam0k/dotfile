-- Highlight chunks
return {
	"shellRaining/hlchunk.nvim",
	event = "VeryLazy",
	config = function()
		require("hlchunk").setup({
			chunk = {
				enable = true,
				style = {
					{ fg = "#d2a6ff" },
					{ fg = "#d95757" }, -- エラーチャンクの色
				},
			},
			indent = {
				enable = true,
				style = {
					"#3a3a3a",
				},
			},
			line_num = {
				enable = false,
			},
			blank = {
				enable = false,
			},
		})
	end,
}
