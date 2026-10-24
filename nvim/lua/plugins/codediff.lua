-- VSCode-style diff viewer for reviewing changes and pull requests
return {
	"esmuellert/codediff.nvim",
	cmd = "CodeDiff",
	init = function()
		-- :Review and the diff tab's working directory (lua/config/review.lua)
		require("config.review").setup()
	end,
	opts = {
		diff = {
			compute_moves = true, -- Detect moved code blocks (align with gm)
		},
		keymaps = {
			view = {
				-- Diff buffers map these with nowait, so keep them off global prefixes
				toggle_layout = "<leader>l", -- Default "t" disables t1-t9/tc/tx
				focus_explorer = "<leader>E", -- Default "<leader>e" is the diagnostic float
				toggle_stage = "<leader>hS", -- Default "-" opens Oil
				toggle_compact = "<leader>z", -- Default "gc" disables gcc
			},
		},
	},
}
