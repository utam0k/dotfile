-- Winbar breadcrumbs
return {
	"Bekaboo/dropbar.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local default_enable = require("dropbar.configs").opts.bar.enable
		require("dropbar").setup({
			bar = {
				-- CodeDiff clears the diff panes' winbars so both sides stay aligned;
				-- a bar on the file side alone shifts it down a line.
				enable = function(buf, win, info)
					if vim.api.nvim_win_is_valid(win) then
						if require("config.review").is_diff_tab(vim.api.nvim_win_get_tabpage(win)) then
							return false
						end
					end
					return default_enable(buf, win, info)
				end,
			},
			sources = {
				path = {
					-- Default resolver is vim.fn.getcwd, which produces long
					-- paths whenever nvim is launched from above the project
					-- root. Anchor on the nearest .git toplevel instead, with
					-- cwd as the fallback for non-git buffers.
					relative_to = function(buf, win)
						local fname = vim.api.nvim_buf_get_name(buf)
						if fname ~= "" then
							local root = vim.fs.root(fname, ".git")
							if root then
								return root
							end
						end
						local ok, cwd = pcall(vim.fn.getcwd, win)
						return ok and cwd or vim.fn.getcwd()
					end,
				},
			},
		})

		local ok, dropbar_api = pcall(require, "dropbar.api")
		if not ok then
			return
		end

		if type(dropbar_api.pick) == "function" then
			vim.keymap.set("n", "<leader>;", dropbar_api.pick, { desc = "Dropbar: Pick symbols in winbar" })
		end
		if type(dropbar_api.goto_context_start) == "function" then
			vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Dropbar: Go to context start" })
		end
		if type(dropbar_api.select_next_context) == "function" then
			vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Dropbar: Select next context" })
		end
	end,
}
