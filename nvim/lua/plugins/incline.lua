-- incline.nvim - Floating statuslines
return {
	"b0o/incline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "BufReadPre",
	config = function()
		require("incline").setup({
			debounce_threshold = {
				falling = 50,
				rising = 10,
			},
			window = {
				placement = {
					horizontal = "right", -- Place on the right side
					vertical = "bottom", -- Place at the bottom
				},
				margin = {
					horizontal = 1,
					vertical = 0, -- Stick to the bottom edge
				},
				width = "fit",
				winhighlight = {
					active = {
						EndOfBuffer = "None",
						Normal = "InclineNormal",
						Search = "None",
					},
					inactive = {
						EndOfBuffer = "None",
						Normal = "InclineNormalNC",
						Search = "None",
					},
				},
			},
			hide = {
				cursorline = false,
				focused_win = false,
				only_win = false,
			},
			render = function(props)
				-- Normal status line rendering
				local bufname = vim.api.nvim_buf_get_name(props.buf)
				local filename = vim.fn.fnamemodify(bufname, ":t")
				local relative_path = ""

				if filename == "" then
					filename = "[No Name]"
				else
					-- Get path relative to current working directory
					relative_path = vim.fn.fnamemodify(bufname, ":.")

					-- Handle long paths
					local max_width = math.floor(vim.o.columns * 0.4) -- 40% of screen width
					if #relative_path > max_width then
						-- First try pathshorten to shorten directory names
						relative_path = vim.fn.pathshorten(relative_path)

						-- If still too long, truncate from beginning
						if #relative_path > max_width then
							relative_path = "..." .. string.sub(relative_path, -(max_width - 3))
						end
					end
				end

				local modified = vim.bo[props.buf].modified

				-- Get git info
				local git_info = ""
				if vim.fn.exists("*FugitiveHead") == 1 then
					local branch = vim.fn.FugitiveHead()
					if branch ~= "" then
						git_info = " " .. branch
					end
				end

				-- Get git diff stats for current file
				local git_stats = ""
				if vim.b[props.buf].gitsigns_status_dict then
					local stats = vim.b[props.buf].gitsigns_status_dict
					local added = stats.added or 0
					local changed = stats.changed or 0
					local removed = stats.removed or 0

					if added > 0 or changed > 0 or removed > 0 then
						local parts = {}
						if added > 0 then
							table.insert(parts, "+" .. added)
						end
						if changed > 0 then
							table.insert(parts, "~" .. changed)
						end
						if removed > 0 then
							table.insert(parts, "-" .. removed)
						end
						git_stats = " " .. table.concat(parts, " ")
					end
				end

				-- Get search count if available
				local search_count = ""
				if vim.v.hlsearch == 1 and props.focused then
					local ok, result = pcall(vim.fn.searchcount, { timeout = 100 })
					if ok and result.total > 0 then
						if result.incomplete == 1 then
							search_count = " ?/?"
						elseif result.total > result.maxcount then
							search_count = string.format(" %d/>%d", result.current, result.maxcount)
						else
							search_count = string.format(" %d/%d", result.current, result.total)
						end
					end
				end

				local components = {}

				-- File path
				table.insert(components, " ")
				if relative_path ~= "" and relative_path ~= filename then
					-- Show full relative path
					table.insert(components, { relative_path, gui = modified and "bold,italic" or "bold" })
				else
					-- Show just filename if no path
					table.insert(components, { filename, gui = modified and "bold,italic" or "bold" })
				end

				-- Modified indicator
				if modified then
					table.insert(components, { " ●", guifg = "#f7768e" })
				end

				-- Git info
				if git_info ~= "" then
					table.insert(components, { git_info, guifg = "#7aa2f7" })
				end

				-- Git stats
				if git_stats ~= "" then
					table.insert(components, { git_stats, guifg = "#9ece6a" })
				end

				-- Search count
				if search_count ~= "" then
					table.insert(components, { search_count, guifg = "#bb9af7" })
				end

				-- Add separator before position info
				table.insert(components, { " | ", guifg = "#565f89" })

				-- Get function context from nvim-navic
				local navic_ok, navic = pcall(require, "nvim-navic")
				if navic_ok and navic.is_available(props.buf) then
					local location = navic.get_location({ highlight = false }, props.buf)
					if location and location ~= "" then
						table.insert(components, { location, guifg = "#7dcfff" })
						table.insert(components, { " | ", guifg = "#565f89" })
					end
				end

				-- Calculate percentage position
				local line = vim.api.nvim_win_get_cursor(props.win)[1]
				local total_lines = vim.api.nvim_buf_line_count(props.buf)
				local percentage = math.floor((line / total_lines) * 100)
				table.insert(components, { string.format("%d%%", percentage), guifg = "#9ece6a" })

				table.insert(components, " ")

				return components
			end,
		})

		-- Set up highlight groups
		vim.api.nvim_set_hl(0, "InclineNormal", { bg = "#1f2335", fg = "#c0caf5" })
		vim.api.nvim_set_hl(0, "InclineNormalNC", { bg = "#1a1b26", fg = "#565f89" })
	end,
}
