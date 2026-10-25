-- Run with: NVIM_LOG_FILE=/dev/null nvim --headless -u NONE -i NONE -n -l tests/review.lua
-- bin/review-worktree is real; gh (including `gh worktree`), :CodeDiff,
-- codediff's session lookup and Telescope are stubbed.
local root = vim.fn.getcwd()
local base = root .. "/.agent/review-check"
vim.fn.delete(base, "rf")
vim.fn.mkdir(base .. "/bin", "p")
vim.opt.runtimepath:prepend(root)

-- gh stub, mirroring gh-worktree: `cd` fails for a missing worktree, `pr --cd`
-- creates it, and both print the path without a newline. `sync` reports to
-- stdout, or fails with $REVIEW_TEST_SYNC_ERROR.
local gh_log = base .. "/gh.log"
vim.fn.writefile({
	"#!/bin/sh",
	'printf "%s\\n" "$*" >> "' .. gh_log .. '"',
	"for number; do :; done",
	'worktree="$PWD/.worktree/pr/pr-$number"',
	'case "$1 $2" in',
	'"worktree cd")',
	'    [ -d "$worktree" ] || { echo "worktree for PR #$number not found" >&2; exit 1; }',
	'    printf "%s" "$worktree" ;;',
	'"worktree pr") mkdir -p "$worktree" && printf "%s" "$worktree" ;;',
	'"worktree sync")',
	'    if [ -n "$REVIEW_TEST_SYNC_ERROR" ]; then echo "$REVIEW_TEST_SYNC_ERROR" >&2; exit 1; fi',
	'    echo "Synced PR #$number to abc1234" ;;',
	"esac",
}, base .. "/bin/gh")
vim.fn.setfperm(base .. "/bin/gh", "rwxr-xr-x")
vim.env.PATH = base .. "/bin:" .. vim.env.PATH

local passed = 0
local function pass(name)
	passed = passed + 1
	print("PASS " .. name)
end
local function gh_calls()
	local calls = vim.fn.filereadable(gh_log) == 1 and vim.fn.readfile(gh_log) or {}
	vim.fn.delete(gh_log)
	return calls
end

local repo = base .. "/repo"
local path = repo .. "/.worktree/pr/pr-1"
vim.fn.mkdir(repo, "p")

local opened, errors = {}, {}
vim.api.nvim_create_user_command("CodeDiff", function(args)
	table.insert(opened, args.args)
end, { nargs = "*" })
vim.notify = function(message, level)
	if level == vim.log.levels.ERROR then
		table.insert(errors, message)
	end
end

local review = require("config.review")
review.setup()

local function run_review(number)
	local before_open, before_error = #opened, #errors
	vim.cmd.cd(vim.fn.fnameescape(repo))
	review.open(number)
	assert(
		vim.wait(10000, function()
			return #opened > before_open or #errors > before_error
		end, 20),
		"review of #" .. number .. " did not finish"
	)
	return opened[before_open + 1], errors[before_error + 1]
end

local ok, err = xpcall(function()
	local args, failure = run_review("1")
	assert(not failure, failure)
	assert(args == "--repo " .. path, "unexpected :CodeDiff arguments: " .. tostring(args))
	local invoked = gh_calls()
	assert(vim.deep_equal(invoked, { "worktree cd 1", "worktree pr --cd 1" }), vim.inspect(invoked))
	pass("creates the review worktree and opens :CodeDiff on it")

	args, failure = run_review("#1")
	assert(not failure, failure)
	assert(args == "--repo " .. path, "sync output leaked into the path: " .. tostring(args))
	invoked = gh_calls()
	assert(
		vim.deep_equal(invoked, { "worktree cd 1", "worktree pr --reuse --cd 1", "worktree sync 1" }),
		vim.inspect(invoked)
	)
	pass("moves an existing worktree to the PR's latest head")

	vim.env.REVIEW_TEST_SYNC_ERROR = "worktree has local changes; use --force to discard them"
	args, failure = run_review("1")
	vim.env.REVIEW_TEST_SYNC_ERROR = nil
	gh_calls()
	assert(not args, "opened a diff although the worktree was not updated")
	assert(failure and failure:match("local changes"), "gh-worktree's error was not shown: " .. tostring(failure))
	pass("shows gh-worktree's error and opens nothing when it refuses")

	args, failure = run_review("abc")
	assert(failure and failure:match("usage"), "invalid number was not refused")
	assert(vim.tbl_isempty(gh_calls()), "gh was called for an invalid number")
	pass("rejects arguments that are not PR numbers")

	-- Diff tabs: stub codediff's session lookup (it is only consulted when loaded).
	local sessions = {}
	package.loaded["codediff.ui.lifecycle"] = {
		get_session = function(tab)
			return sessions[tab]
		end,
		get_git_context = function(tab)
			return sessions[tab]
		end,
	}
	local function open_diff_tab(git_root)
		vim.cmd.tabnew()
		local tab = vim.api.nvim_get_current_tabpage()
		sessions[tab] = { git_root = git_root }
		vim.api.nvim_exec_autocmds("User", { pattern = "CodeDiffOpen", data = { tabpage = tab, mode = "explorer" } })
		return tab
	end
	vim.cmd.cd(vim.fn.fnameescape(repo))
	local first = vim.api.nvim_get_current_tabpage()
	local diff_tab = open_diff_tab(path)
	assert(vim.fn.getcwd() == path and vim.fn.haslocaldir(-1, 0) == 1, "diff tab cwd: " .. vim.fn.getcwd())
	assert(vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(first)) == repo, "other tabs changed cwd")
	vim.cmd.tabnew()
	assert(vim.fn.getcwd() == path, "a tab opened from the diff tab did not inherit the worktree")
	vim.cmd.tabclose()
	pass("a diff tab of another repository gets that repository as tab-local cwd")

	vim.fn.mkdir(repo .. "/sub", "p")
	vim.cmd.cd(vim.fn.fnameescape(repo .. "/sub"))
	open_diff_tab(repo)
	assert(vim.fn.haslocaldir(-1, 0) == 0 and vim.fn.getcwd() == repo .. "/sub", "plain :CodeDiff changed cwd")
	pass("a diff tab of the current repository keeps the cwd")

	local calls = {}
	package.loaded["telescope.builtin"] = setmetatable({}, {
		__index = function(_, picker)
			return function(opts)
				table.insert(calls, { picker = picker, opts = opts })
			end
		end,
	})
	vim.api.nvim_set_current_tabpage(diff_tab)
	review.lsp("lsp_definitions")
	assert(calls[1].picker == "lsp_definitions" and calls[1].opts.jump_type == "tab", vim.inspect(calls[1]))
	assert(type(calls[1].opts.attach_mappings) == "function", "picker selections would replace the diff pane")
	vim.api.nvim_set_current_tabpage(first)
	review.lsp("lsp_references")
	assert(vim.tbl_isempty(calls[2].opts), "LSP jumps outside diff tabs changed: " .. vim.inspect(calls[2]))
	pass("LSP jumps open a new tab only from diff tabs")

	-- codediff recreates the explorer window whenever the file list is shown again.
	local explorer = vim.api.nvim_create_buf(false, true)
	vim.bo[explorer].filetype = "codediff-explorer"
	vim.cmd.vsplit()
	vim.api.nvim_win_set_buf(0, explorer)
	assert(vim.wo.winbar:match("%]f") and vim.wo.winbar:match("g%?"), "no key hint: " .. vim.wo.winbar)
	local width = vim.api.nvim_eval_statusline(vim.wo.winbar, { use_winbar = true, maxwidth = 200 }).width
	assert(width <= 40, "hint is wider than codediff's 40-column explorer: " .. width)
	vim.cmd.close()
	vim.cmd.vsplit()
	vim.api.nvim_win_set_buf(0, explorer)
	assert(vim.wo.winbar:match("%]f"), "hint missing after the explorer was shown again")
	vim.cmd.enew()
	assert(vim.wo.winbar == "", "hint leaked to another buffer: " .. vim.wo.winbar)
	pass("the file list shows the main keys, also after it is shown again")
end, debug.traceback)
if not ok then
	error(err)
end
print("PASS: " .. passed .. " review checks")
