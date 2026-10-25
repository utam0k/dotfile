-- Run with: NVIM_LOG_FILE=/dev/null nvim --headless -u NONE -i NONE -n -l tests/review.lua
-- Uses real git repositories in a scratch directory; gh, :CodeDiff, codediff's
-- session lookup and Telescope are stubbed.
local root = vim.fn.getcwd()
local base = root .. "/.agent/review-check"
vim.fn.delete(base, "rf")
vim.fn.mkdir(base .. "/bin", "p")
vim.opt.runtimepath:prepend(root)

-- Isolate git from the user's config (commit signing, ignores, credentials).
vim.fn.writefile({
	"[user]",
	"\tname = Review Test",
	"\temail = review@example.com",
	"[init]",
	"\tdefaultBranch = main",
}, base .. "/gitconfig")
vim.env.GIT_CONFIG_GLOBAL = base .. "/gitconfig"
vim.env.GIT_CONFIG_NOSYSTEM = "1"

-- gh stub: records its arguments and prints what bin/review-worktree's --jq selects.
local gh_log = base .. "/gh.log"
vim.fn.writefile({
	"#!/bin/sh",
	'printf "%s\\n" "$*" >> "' .. gh_log .. '"',
	[[printf 'main\tTest PR\n']],
}, base .. "/bin/gh")
vim.fn.setfperm(base .. "/bin/gh", "rwxr-xr-x")
vim.env.PATH = base .. "/bin:" .. vim.env.PATH

local passed = 0
local function pass(name)
	passed = passed + 1
	print("PASS " .. name)
end
local function git(cwd, ...)
	local cmd = { "git", ... }
	local result = vim.system(cmd, { cwd = cwd, text = true }):wait()
	assert(result.code == 0, table.concat(cmd, " ") .. ": " .. result.stderr)
	return vim.trim(result.stdout)
end
local function last_gh_call()
	local lines = vim.fn.readfile(gh_log)
	return lines[#lines]
end

local remote = base .. "/remote.git"
local seed = base .. "/seed"
local clone = base .. "/clone"
git(base, "init", "--quiet", "--bare", remote)
git(base, "init", "--quiet", seed)
vim.fn.writefile({ "base" }, seed .. "/file.txt")
git(seed, "add", ".")
git(seed, "commit", "--quiet", "-m", "base")
git(seed, "push", "--quiet", remote, "main")

-- Publish a PR head the way GitHub does: a commit on main under refs/pull/<n>/head.
local function push_pr(n, content)
	git(seed, "checkout", "--quiet", "-B", "pr" .. n, "main")
	vim.fn.writefile({ content }, seed .. "/file.txt")
	git(seed, "commit", "--quiet", "-am", content)
	git(seed, "push", "--quiet", "--force", remote, "HEAD:refs/pull/" .. n .. "/head")
	return git(seed, "rev-parse", "HEAD")
end

git(base, "clone", "--quiet", remote, clone)
vim.fn.writefile({ ".worktree/" }, clone .. "/.git/info/exclude")
-- GitHub-looking remote URLs that git rewrites to the local bare repository.
local function add_alias(url)
	git(clone, "config", "--add", "url." .. remote .. ".insteadOf", url)
end
add_alias("https://github.com/test/repo.git")
git(clone, "remote", "set-url", "origin", "https://github.com/test/repo.git")

-- Advance main after cloning so the review has to fetch the base branch.
git(seed, "checkout", "--quiet", "main")
vim.fn.writefile({ "base" }, seed .. "/other.txt")
git(seed, "add", ".")
git(seed, "commit", "--quiet", "-m", "main moves on")
git(seed, "push", "--quiet", remote, "main")
local main_head = git(seed, "rev-parse", "HEAD")

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

local function run_review(number, cwd)
	local before_open, before_error = #opened, #errors
	vim.cmd.cd(vim.fn.fnameescape(cwd or clone))
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
	local path = clone .. "/.worktree/pr/pr-1"
	local head = push_pr(1, "first")
	local args, failure = run_review("1")
	assert(not failure, failure)
	assert(git(path, "rev-parse", "HEAD") == head, "worktree is not at the PR head")
	assert(git(path, "status", "--porcelain", "--branch"):match("^## HEAD %(no branch%)"), "worktree is not detached")
	assert(args == "--repo " .. path .. " origin/main...", "unexpected :CodeDiff arguments: " .. tostring(args))
	assert(last_gh_call():match("^pr view 1 %-%-repo github%.com/test/repo "), last_gh_call())
	assert(git(clone, "rev-parse", "origin/main") == main_head, "base branch was not fetched")
	assert(git(clone, "symbolic-ref", "--short", "HEAD") == "main", "main worktree left its branch")
	pass("creates a detached PR worktree, fetches the base and opens the merge-base diff")

	head = push_pr(1, "second")
	args, failure = run_review("#1")
	assert(not failure, failure)
	assert(git(path, "rev-parse", "HEAD") == head, "worktree was not moved to the updated PR head")
	pass("reuses the worktree and moves it to the updated PR head")

	args, failure = run_review("1", path)
	assert(not failure, failure)
	assert(args == "--repo " .. path .. " origin/main...", "run from the PR worktree nested a worktree: " .. args)
	pass("run from inside a PR worktree resolves the main worktree")

	local reviewed = head
	vim.fn.writefile({ "my notes" }, path .. "/file.txt")
	push_pr(1, "third")
	args, failure = run_review("1")
	assert(failure and failure:match("uncommitted changes"), "dirty worktree was not refused: " .. tostring(failure))
	assert(git(path, "rev-parse", "HEAD") == reviewed, "dirty worktree was moved")
	assert(vim.fn.readfile(path .. "/file.txt")[1] == "my notes", "local edit was lost")
	git(path, "checkout", "--", "file.txt")
	pass("refuses to touch a worktree with uncommitted changes")

	vim.fn.mkdir(clone .. "/.worktree/pr/pr-2", "p")
	push_pr(2, "two")
	args, failure = run_review("2")
	assert(failure and failure:match("is not a git worktree"), "plain directory was not refused: " .. tostring(failure))
	assert(git(clone, "symbolic-ref", "--short", "HEAD") == "main", "main worktree was detached")
	pass("refuses a plain directory instead of acting on the main worktree")

	add_alias("git@github.com:up/repo.git")
	git(clone, "remote", "add", "upstream", "git@github.com:up/repo.git")
	args, failure = run_review("1")
	assert(not failure, failure)
	assert(args == "--repo " .. path .. " upstream/main...", "upstream was not preferred: " .. args)
	assert(last_gh_call():match("%-%-repo github%.com/up/repo "), last_gh_call())
	add_alias("ssh://git@github.example.com:2222/team/proj.git")
	git(clone, "remote", "set-url", "upstream", "ssh://git@github.example.com:2222/team/proj.git")
	args, failure = run_review("1")
	assert(not failure, failure)
	assert(last_gh_call():match("%-%-repo github%.example%.com/team/proj "), last_gh_call())
	pass("prefers upstream and passes gh the repository of scp and ssh URLs")

	args, failure = run_review("abc")
	assert(failure and failure:match("usage"), "invalid number was not refused")
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
	vim.cmd.cd(vim.fn.fnameescape(clone))
	local first = vim.api.nvim_get_current_tabpage()
	local diff_tab = open_diff_tab(path)
	assert(vim.fn.getcwd() == path and vim.fn.haslocaldir(-1, 0) == 1, "diff tab cwd: " .. vim.fn.getcwd())
	assert(vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(first)) == clone, "other tabs changed cwd")
	vim.cmd.tabnew()
	assert(vim.fn.getcwd() == path, "a tab opened from the diff tab did not inherit the worktree")
	vim.cmd.tabclose()
	pass("a diff tab of another repository gets that repository as tab-local cwd")

	vim.fn.mkdir(clone .. "/sub", "p")
	vim.cmd.cd(vim.fn.fnameescape(clone .. "/sub"))
	open_diff_tab(clone)
	assert(vim.fn.haslocaldir(-1, 0) == 0 and vim.fn.getcwd() == clone .. "/sub", "plain :CodeDiff changed cwd")
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
