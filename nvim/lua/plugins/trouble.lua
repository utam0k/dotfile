-- Trouble.nvim - Pretty diagnostics, references, telescope results, quickfix and location list
return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = "Trouble",
	keys = {
		{
			"<space>t",
			function()
				vim.cmd("Trouble combined toggle")
				-- Focus trouble window after opening
				vim.defer_fn(function()
					local trouble = require("trouble")
					if trouble.is_open() then
						-- Find trouble window and focus it
						for _, win in ipairs(vim.api.nvim_list_wins()) do
							local buf = vim.api.nvim_win_get_buf(win)
							local ft = vim.api.nvim_buf_get_option(buf, "filetype")
							if ft == "trouble" then
								vim.api.nvim_set_current_win(win)
								break
							end
						end
					end
				end, 50)
			end,
			desc = "Diagnostics & Symbols (Trouble)",
		},
		{
			"<space>q",
			"<cmd>Trouble qflist toggle<cr>",
			desc = "Quickfix List (Trouble)",
		},
	},
	opts = {
		modes = {
			-- Combined diagnostics and symbols mode
			combined = {
				desc = "Diagnostics and Symbols",
				sections = { "diagnostics", "lsp_document_symbols" },
				filter = { buf = 0 }, -- Current buffer only
				focus = false,
				auto_preview = true, -- Enabled by default
				auto_refresh = true,
				win = {
					position = "right",
					relative = "win",
					size = 0.3,
				},
				preview = {
					type = "split",
					relative = "win",
					position = "bottom",
					size = 0.3,
					scratch = true,
				},
			},
		},
		-- Use the diagnostic signs we defined
		signs = {
			error = "❗",
			warning = "⚠️",
			hint = "💡",
			information = "ℹ️",
			other = "●",
		},
		-- Customize the icons for file types and kinds
		icons = {
			indent = {
				middle = " ",
				last = " ",
				top = " ",
				ws = "│  ",
			},
			folder_closed = "",
			folder_open = "",
			kinds = {},
		},
		indent_lines = true,
		-- Key mappings in trouble window
		keys = {
			["?"] = "help",
			r = "refresh",
			R = "toggle_refresh",
			q = "close",
			o = "jump_close",
			["<esc>"] = "cancel",
			["<cr>"] = "jump",
			["<2-leftmouse>"] = "jump",
			["<c-s>"] = "jump_split",
			["<c-v>"] = "jump_vsplit",
			-- go down to next item (accepts count)
			j = "next",
			["<down>"] = "next",
			["<tab>"] = "next",
			-- go up to prev item (accepts count)
			k = "prev",
			["<up>"] = "prev",
			["<s-tab>"] = "prev",
			dd = "delete",
			d = { action = "delete", mode = "v" },
			i = "inspect",
			p = "preview",
			P = "toggle_preview",
			zo = "fold_open",
			zO = "fold_open_recursive",
			zc = "fold_close",
			zC = "fold_close_recursive",
			za = "fold_toggle",
			zA = "fold_toggle_recursive",
			zm = "fold_more",
			zM = "fold_close_all",
			zr = "fold_reduce",
			zR = "fold_open_all",
			zx = "fold_update",
			zX = "fold_update_all",
			zn = "fold_disable",
			zN = "fold_enable",
			zi = "fold_toggle_enable",
			gb = { -- example of a custom action that toggles the active view filter
				action = function(view)
					view:filter({ buf = 0 }, { toggle = true })
				end,
				desc = "Toggle Current Buffer Filter",
			},
			s = { -- example of a custom action that toggles the severity
				action = function(view)
					local f = view:get_filter("severity")
					local severity = ((f and f.filter.severity or 0) + 1) % 5
					view:filter({ severity = severity }, {
						id = "severity",
						template = "{hl:Title}Filter:{hl} {severity}",
						del = severity == 0,
					})
				end,
				desc = "Toggle Severity Filter",
			},
			["<"] = { -- Decrease window width
				action = function(view)
					local win = view.win.win
					if win and vim.api.nvim_win_is_valid(win) then
						local width = vim.api.nvim_win_get_width(win)
						local new_width = math.max(20, width - 5)
						vim.api.nvim_win_set_width(win, new_width)
					end
				end,
				desc = "Decrease Width",
			},
			[">"] = { -- Increase window width
				action = function(view)
					local win = view.win.win
					if win and vim.api.nvim_win_is_valid(win) then
						local width = vim.api.nvim_win_get_width(win)
						local new_width = width + 5
						vim.api.nvim_win_set_width(win, new_width)
					end
				end,
				desc = "Increase Width",
			},
		},
		folds = {
			fold_closed = "",
			fold_open = "",
			folded = true,
			indent = 1,
		},
		-- Render logic
		flatten = true,
		format = "{level} {text:ts} {pos}",
		format_count = "({count})",
		multiline = true,
	},
}