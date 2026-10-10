-- GitHub Copilot — Lua-native engine (replaces github/copilot.vim)
-- Tab accepts visible suggestions via blink.lua; Alt+L also accepts.
return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	dependencies = {
		{
			"copilotlsp-nvim/copilot-lsp",
			-- The local freshness guard uses this version's NES preview API.
			commit = "1b6d8273594643f51bb4c0c1d819bdb21b42159d",
		},
	},
	opts = {
		suggestion = {
			enabled = true,
			auto_trigger = true,
			-- Keep suggestions visible alongside blink's menu (Enter accepts blink).
			-- Defaults: <M-l> accept, <M-]> next, <M-[> prev, <C-]> dismiss.
		},
		panel = { enabled = false },
		nes = {
			enabled = true,
			keymap = { dismiss = "<Esc>" },
		},
		-- Filetypes: copilot.lua's defaults disable yaml/markdown/help/
		-- gitcommit/gitrebase/hgcommit/svn/cvs. Keep those.
	},
	config = function(_, opts)
		local nes = require("config.copilot_nes")
		nes.setup()
		require("copilot").setup(opts)
		vim.keymap.set("n", "<Tab>", function()
			if nes.accept() then
				return ""
			end
			return "<C-I>"
		end, { expr = true, desc = "Accept Copilot edit or jump forward" })

		-- Preserve :CopilotToggle from the copilot.vim era.
		vim.api.nvim_create_user_command("CopilotToggle", function()
			vim.cmd("Copilot toggle")
		end, {})
	end,
}
