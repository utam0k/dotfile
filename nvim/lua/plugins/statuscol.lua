return {
	"luukvbaal/statuscol.nvim",
	event = "VeryLazy",
	config = function()
		local builtin = require("statuscol.builtin")
		_G.NeotestGutterClick = require("config.test_gutter").click
		-- Allow right-click to reach the gutter callback instead of the popup menu.
		vim.opt.mousemodel = "extend"
		require("statuscol").setup({
			ft_ignore = { "NvimTree", "aerial", "oil" },
			bt_ignore = { "nofile", "prompt", "terminal", "quickfix" },
			segments = {
				{ text = { "%C" }, click = "v:lua.ScFa" },
				{ sign = { name = { ".*" }, namespace = { ".*" }, maxwidth = 1, auto = true } },
				{
					sign = { name = { "^neotest_" }, maxwidth = 1, colwidth = 1, auto = true },
					click = "v:lua.NeotestGutterClick",
				},
				-- Leave line numbers without statuscol's default DAP click handler.
				{ text = { builtin.lnumfunc, " " }, condition = { true, builtin.not_empty } },
			},
		})
	end,
}
