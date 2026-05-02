-- GitHub Copilot — Lua-native engine (replaces github/copilot.vim)
-- Default accept keymap is <M-l> (Alt+L); see suggestion.keymap below.
-- Requires Node.js >= 20 for the language server.
return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	opts = {
		suggestion = {
			enabled = true,
			auto_trigger = true,
			-- Defaults: <M-l> accept, <M-]> next, <M-[> prev, <C-]> dismiss.
		},
		panel = { enabled = false },
		-- Filetypes: copilot.lua's defaults disable yaml/markdown/help/
		-- gitcommit/gitrebase/hgcommit/svn/cvs. Keep those.
	},
	config = function(_, opts)
		require("copilot").setup(opts)

		-- Hide the inline suggestion while blink.cmp's menu is open so the
		-- two completion surfaces don't overlap visually.
		local group = vim.api.nvim_create_augroup("user_copilot_blink", { clear = true })
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "BlinkCmpMenuOpen",
			callback = function()
				vim.b.copilot_suggestion_hidden = true
			end,
			desc = "Hide Copilot ghost text while blink.cmp menu is open",
		})
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "BlinkCmpMenuClose",
			callback = function()
				vim.b.copilot_suggestion_hidden = false
			end,
			desc = "Show Copilot ghost text when blink.cmp menu closes",
		})

		-- Preserve :CopilotToggle from the copilot.vim era.
		vim.api.nvim_create_user_command("CopilotToggle", function()
			vim.cmd("Copilot toggle")
		end, {})
	end,
}
