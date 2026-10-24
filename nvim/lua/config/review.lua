-- Review GitHub pull requests in a dedicated git worktree.
--
-- `:Review <number>` checks the PR head out into
-- <repo>/.worktree/pr/pr-<number> with bin/review-worktree (shared with the
-- zsh `review` command) and opens :CodeDiff against the merge base of the
-- PR's base branch, the same range as GitHub's "Files changed".
--
-- Diff tabs get a tab-local cwd in the repository they show, and LSP jumps
-- from a diff tab open in a new tab so the diff layout stays intact.

local M = {}

-- This file is lua/config/review.lua inside the nvim directory of the dotfiles.
local script = vim.fn.fnamemodify(vim.uv.fs_realpath(debug.getinfo(1, "S").source:sub(2)), ":h:h:h:h")
	.. "/bin/review-worktree"

local function notify(message, level)
	vim.notify("Review: " .. message, level or vim.log.levels.INFO)
end

function M.open(number)
	number = tostring(number or ""):gsub("^#", "")
	if not number:match("^%d+$") then
		notify("usage: :Review <pull request number>", vim.log.levels.ERROR)
		return
	end
	notify("preparing #" .. number)
	-- Fetching can take a while, so wait for the worktree without blocking.
	vim.system({ script, number }, { cwd = vim.fn.getcwd(), text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				notify(vim.trim(result.stderr), vim.log.levels.ERROR)
				return
			end
			local path, base = unpack(vim.split(vim.trim(result.stdout), "\n"))
			vim.cmd(("CodeDiff --repo %s %s..."):format(vim.fn.fnameescape(path), base))
		end)
	end)
end

-- Give a diff tab a tab-local cwd in the repository it shows, unless the
-- current cwd is already inside it (plain :CodeDiff keeps its cwd).
function M.follow_repo(tabpage)
	local ok, context = pcall(function()
		return require("codediff.ui.lifecycle").get_git_context(tabpage)
	end)
	local root = ok and context and context.git_root
	if not root or not vim.api.nvim_tabpage_is_valid(tabpage) then
		return
	end
	vim.api.nvim_win_call(vim.api.nvim_tabpage_get_win(tabpage), function()
		local cwd = vim.fn.getcwd()
		if not vim.fs.relpath(root, vim.uv.fs_realpath(cwd) or cwd) then
			vim.cmd.tcd(vim.fn.fnameescape(root))
		end
	end)
end

local function in_diff_tab()
	local lifecycle = package.loaded["codediff.ui.lifecycle"]
	return lifecycle ~= nil and lifecycle.get_session(vim.api.nvim_get_current_tabpage()) ~= nil
end

-- Run a Telescope LSP picker; inside a diff tab the target opens in a new tab.
function M.lsp(picker)
	local opts = {}
	if in_diff_tab() then
		opts.jump_type = "tab"
		opts.attach_mappings = function()
			local actions = require("telescope.actions")
			actions.select_default:replace(actions.select_tab)
			return true
		end
	end
	require("telescope.builtin")[picker](opts)
end

function M.setup()
	vim.api.nvim_create_user_command("Review", function(args)
		M.open(args.args)
	end, { nargs = 1, desc = "Review a GitHub pull request in a worktree" })

	vim.api.nvim_create_autocmd("User", {
		group = vim.api.nvim_create_augroup("ReviewDiffTab", { clear = true }),
		pattern = "CodeDiffOpen",
		callback = function(args)
			M.follow_repo(args.data.tabpage)
		end,
		desc = "Set the diff tab's cwd to the repository it shows",
	})
end

return M
