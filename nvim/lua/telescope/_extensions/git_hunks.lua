-- Git hunks picker for Telescope
local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

-- Get git hunks with line numbers
local function get_git_hunks()
	local hunks = {}

	-- Get git root directory
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 or not git_root then
		vim.notify("Not in a git repository", vim.log.levels.ERROR)
		return hunks
	end

	-- Run git diff from git root to get consistent paths
	local cmd = string.format("cd %s && git diff -U0 --no-color", vim.fn.shellescape(git_root))
	local result = vim.fn.systemlist(cmd)

	local current_file = nil
	local i = 1
	while i <= #result do
		local line = result[i]

		-- Match file header
		local file = line:match("^%+%+%+ b/(.+)$")
		if file then
			current_file = file
		end

		-- Match hunk header
		if current_file and line:match("^@@") then
			local old_start, old_count, new_start, new_count = line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")

			if new_start then
				local line_num = tonumber(new_start)
				local context = line:match("@@.*@@ (.*)$") or ""

				-- Look ahead to get actual changes
				local j = i + 1
				local has_add = false
				local has_del = false
				local first_change = nil

				while j <= #result and result[j]:match("^[+-]") do
					local change_line = result[j]
					if change_line:match("^%+") then
						has_add = true
						if not first_change then
							first_change = change_line:sub(2)
						end
					elseif change_line:match("^%-") then
						has_del = true
						if not first_change then
							first_change = change_line:sub(2)
						end
					end
					j = j + 1
				end

				-- Create one entry per hunk
				if first_change then
					local change_type = "~"
					if has_add and not has_del then
						change_type = "+"
					elseif has_del and not has_add then
						change_type = "-"
					end

					table.insert(hunks, {
						filename = current_file,
						lnum = line_num,
						text = first_change:sub(1, 60),
						type = change_type,
						git_root = git_root,
					})
				end
			end
		end

		i = i + 1
	end

	if #hunks == 0 then
		vim.notify("No git hunks found", vim.log.levels.INFO)
	end

	return hunks
end

-- Create the git hunks picker
function M.git_hunks()
	local hunks = get_git_hunks()

	pickers
		.new({}, {
			prompt_title = "Git Hunks",
			finder = finders.new_table({
				results = hunks,
				entry_maker = function(hunk)
					local displayer = entry_display.create({
						separator = " ",
						items = {
							{ width = 35 },
							{ width = 6 },
							{ width = 3 },
							{ remaining = true },
						},
					})

					-- Change type indicators
					local type_sign = {
						["+"] = "[+]",
						["-"] = "[-]",
						["~"] = "[~]",
					}

					local type_hl = {
						["+"] = "DiffAdd",
						["-"] = "DiffDelete",
						["~"] = "DiffChange",
					}

					return {
						value = hunk,
						display = function(entry)
							return displayer({
								{ entry.value.filename, "TelescopeResultsIdentifier" },
								{ tostring(entry.value.lnum), "TelescopeResultsNumber" },
								{
									type_sign[entry.value.type] or "[?]",
									type_hl[entry.value.type] or "TelescopeResultsComment",
								},
								{ entry.value.text, "TelescopeResultsString" },
							})
						end,
						ordinal = hunk.filename .. " " .. hunk.lnum .. " " .. hunk.text,
						path = hunk.git_root .. "/" .. hunk.filename,
						lnum = hunk.lnum,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.grep_previewer({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						vim.cmd("edit " .. vim.fn.fnameescape(selection.path))
						vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
					end
				end)
				return true
			end,
		})
		:find()
end

-- Search within git diffs
function M.search_git_diffs()
	require("telescope.builtin").live_grep({
		additional_args = function()
			-- Search only in files that have changes
			local changed_files = vim.fn.systemlist("git diff --name-only")
			if #changed_files == 0 then
				vim.notify("No changed files to search", vim.log.levels.INFO)
				return {}
			end
			return vim.list_extend({ "--" }, changed_files)
		end,
		prompt_title = "Search in Git Changes",
	})
end

return M
