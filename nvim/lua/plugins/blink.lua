-- Completion (blink.cmp — replaces nvim-cmp + cmp-* dep stack)
return {
	"saghen/blink.cmp",
	-- Pin to v1.x release line so the plugin auto-downloads the prebuilt
	-- Rust fuzzy matcher (avoids needing a local cargo toolchain).
	version = "1.*",
	event = "InsertEnter",
	dependencies = {
		"saghen/blink.lib",
		"L3MON4D3/LuaSnip",
		"rafamadriz/friendly-snippets",
		"echasnovski/mini.icons",
	},
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- 'enter' = <CR> accepts, plus the common C-n/C-p/C-space/C-e bindings.
		keymap = { preset = "enter" },
		snippets = { preset = "luasnip" },
		signature = { enabled = true },
		-- Prefer the Rust matcher, fall back to Lua with a warning if unavailable.
		fuzzy = { implementation = "prefer_rust_with_warning" },
		completion = {
			documentation = { auto_show = true, auto_show_delay_ms = 250 },
			menu = {
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind", gap = 1 },
					},
					-- Pull kind icons + their highlight groups from mini.icons.
					components = {
						kind_icon = {
							text = function(ctx)
								local icon = require("mini.icons").get("lsp", ctx.kind)
								return icon and (icon .. " ") or ctx.kind_icon
							end,
							highlight = function(ctx)
								local _, hl = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
						kind = {
							highlight = function(ctx)
								local _, hl = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
					},
				},
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				toml = { inherit_defaults = true, "crates" },
			},
			providers = {
				crates = {
					name = "crates",
					module = "crates.completion.blink",
					score_offset = 100,
				},
			},
		},
	},
	config = function(_, opts)
		require("mini.icons").setup({})
		require("blink.cmp").setup(opts)
		-- Load friendly-snippets bundle into LuaSnip (not done by blink's preset).
		require("luasnip.loaders.from_vscode").lazy_load()
	end,
}
