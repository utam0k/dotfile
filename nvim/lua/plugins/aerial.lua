-- Code outline viewer (replaces tagbar)
return {
	"stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	cmd = { "AerialToggle", "AerialOpen", "AerialInfo" },
	keys = {
		{ "<leader>o", "<cmd>AerialToggle<cr>", desc = "Toggle outline" },
		{ "<F8>", "<cmd>AerialToggle<cr>", desc = "Toggle Aerial" },
		{ "{", "<cmd>AerialPrev<cr>", desc = "Previous symbol" },
		{ "}", "<cmd>AerialNext<cr>", desc = "Next symbol" },
	},
	config = function()
		require("aerial").setup({
			backends = { "treesitter", "lsp", "markdown", "man" },
			layout = {
				max_width = { 40, 0.2 },
				width = nil,
				min_width = 20,
				default_direction = "right",
				placement = "window",
			},
			attach_mode = "window",
			close_automatic_events = { "unsupported" },
			show_icons = true,
			keymaps = {
				["?"] = "actions.show_help",
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.jump",
				["<2-LeftMouse>"] = "actions.jump",
				["<C-v>"] = "actions.jump_vsplit",
				["<C-s>"] = "actions.jump_split",
				["p"] = "actions.scroll",
				["<C-j>"] = "actions.down_and_scroll",
				["<C-k>"] = "actions.up_and_scroll",
				["{"] = "actions.prev",
				["}"] = "actions.next",
				["[["] = "actions.prev_up",
				["]]"] = "actions.next_up",
				["q"] = "actions.close",
				["o"] = "actions.tree_toggle",
				["za"] = "actions.tree_toggle",
				["O"] = "actions.tree_toggle_recursive",
				["zA"] = "actions.tree_toggle_recursive",
				["l"] = "actions.tree_open",
				["zo"] = "actions.tree_open",
				["L"] = "actions.tree_open_recursive",
				["zO"] = "actions.tree_open_recursive",
				["h"] = "actions.tree_close",
				["zc"] = "actions.tree_close",
				["H"] = "actions.tree_close_recursive",
				["zC"] = "actions.tree_close_recursive",
				["zr"] = "actions.tree_increase_fold_level",
				["zR"] = "actions.tree_open_all",
				["zm"] = "actions.tree_decrease_fold_level",
				["zM"] = "actions.tree_close_all",
				["zx"] = "actions.tree_sync_folds",
				["zX"] = "actions.tree_sync_folds",
			},
			filter_kind = false,
			highlight_mode = "split_width",
			highlight_on_hover = true,
			-- Icons with distinctive symbols
			icons = {
				File = " ",
				Module = " ",
				Namespace = " ",
				Package = " ",
				Class = " ",
				Method = " ",
				Property = " ",
				Field = " ",
				Constructor = " ",
				Enum = " ",
				Interface = " ",
				Function = " ",
				Variable = " ",
				Constant = " ",
				String = " ",
				Number = " ",
				Boolean = "󰨙 ",
				Array = " ",
				Object = " ",
				Key = " ",
				Null = "󰟢 ",
				EnumMember = " ",
				Struct = " ",
				Event = " ",
				Operator = " ",
				TypeParameter = " ",
			},
			nerd_font = "auto",
			show_guides = true,
			guides = {
				mid_item = "├─",
				last_item = "└─",
				nested_top = "│ ",
				whitespace = "  ",
			},
			-- Floating preview configuration
			float = {
				border = "rounded",
				relative = "cursor",
				max_height = 0.9,
				height = nil,
				max_width = 0.5,
				width = nil,
				override = function(conf, source_winid)
					conf.anchor = "NE"
					conf.row = 0
					conf.col = -1
					return conf
				end,
			},
			-- Highlight configuration
			highlight_closest = true,
			highlight_on_jump = 300,
			-- Post-open hook
			on_attach = function(bufnr)
				-- Additional highlight customization
				vim.api.nvim_buf_set_option(bufnr, "winhl", "Normal:NormalFloat")
			end,
		})

		-- Setup custom highlights for Aerial
		local function setup_aerial_highlights()
			-- Get base colors from current colorscheme
			local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
			local comment = vim.api.nvim_get_hl(0, { name = "Comment" })
			local function_hl = vim.api.nvim_get_hl(0, { name = "Function" })
			local type_hl = vim.api.nvim_get_hl(0, { name = "Type" })
			local constant_hl = vim.api.nvim_get_hl(0, { name = "Constant" })
			local keyword_hl = vim.api.nvim_get_hl(0, { name = "Keyword" })

			-- Set aerial-specific highlights
			vim.api.nvim_set_hl(0, "AerialClass", { fg = type_hl.fg, bold = true })
			vim.api.nvim_set_hl(0, "AerialClassIcon", { fg = type_hl.fg })
			vim.api.nvim_set_hl(0, "AerialFunction", { fg = function_hl.fg })
			vim.api.nvim_set_hl(0, "AerialFunctionIcon", { fg = function_hl.fg })
			vim.api.nvim_set_hl(0, "AerialMethod", { fg = function_hl.fg })
			vim.api.nvim_set_hl(0, "AerialMethodIcon", { fg = function_hl.fg })
			vim.api.nvim_set_hl(0, "AerialStruct", { fg = type_hl.fg })
			vim.api.nvim_set_hl(0, "AerialStructIcon", { fg = type_hl.fg })
			vim.api.nvim_set_hl(0, "AerialEnum", { fg = type_hl.fg })
			vim.api.nvim_set_hl(0, "AerialEnumIcon", { fg = type_hl.fg })
			vim.api.nvim_set_hl(0, "AerialInterface", { fg = type_hl.fg })
			vim.api.nvim_set_hl(0, "AerialInterfaceIcon", { fg = type_hl.fg })
			vim.api.nvim_set_hl(0, "AerialModule", { fg = keyword_hl.fg })
			vim.api.nvim_set_hl(0, "AerialModuleIcon", { fg = keyword_hl.fg })
			vim.api.nvim_set_hl(0, "AerialNamespace", { fg = keyword_hl.fg })
			vim.api.nvim_set_hl(0, "AerialNamespaceIcon", { fg = keyword_hl.fg })
			vim.api.nvim_set_hl(0, "AerialConstant", { fg = constant_hl.fg })
			vim.api.nvim_set_hl(0, "AerialConstantIcon", { fg = constant_hl.fg })
			vim.api.nvim_set_hl(0, "AerialVariable", { fg = normal.fg })
			vim.api.nvim_set_hl(0, "AerialVariableIcon", { fg = normal.fg })

			-- Highlight for current position
			local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine" })
			vim.api.nvim_set_hl(0, "AerialLine", { bg = cursorline.bg, bold = true })
			vim.api.nvim_set_hl(0, "AerialLineNC", { bg = cursorline.bg })

			-- Guide highlights
			vim.api.nvim_set_hl(0, "AerialGuide", { fg = comment.fg })
		end

		-- Define custom highlight groups on ColorScheme change
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = setup_aerial_highlights,
		})

		-- Apply highlights immediately
		setup_aerial_highlights()

		-- Integration with telescope
		vim.keymap.set("n", "<leader>fa", "<cmd>Telescope aerial<cr>", { desc = "Search symbols (Aerial)" })
	end,
}

