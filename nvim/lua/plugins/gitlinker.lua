-- Generate shareable git permalinks for the current file/selection
return {
	"ruifm/gitlinker.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{
			"<leader>gy",
			function()
				require("gitlinker").get_buf_range_url("n")
			end,
			desc = "Copy git permalink",
		},
		{
			"<leader>gy",
			function()
				require("gitlinker").get_buf_range_url("v")
			end,
			mode = "v",
			desc = "Copy git permalink",
		},
		{
			"<leader>gB",
			function()
				require("gitlinker").get_buf_range_url("n", {
					action_callback = require("gitlinker.actions").open_in_browser,
				})
			end,
			desc = "Open git permalink",
		},
		{
			"<leader>gB",
			function()
				require("gitlinker").get_buf_range_url("v", {
					action_callback = require("gitlinker.actions").open_in_browser,
				})
			end,
			mode = "v",
			desc = "Open git permalink",
		},
		{
			"<leader>gY",
			function()
				require("gitlinker").get_repo_url()
			end,
			desc = "Copy repo URL",
		},
		{
			"<leader>gR",
			function()
				local actions = require("gitlinker.actions")

				local function git(args, cwd)
					local cmd = { "git" }
					if cwd then
						vim.list_extend(cmd, { "-C", cwd })
					end
					vim.list_extend(cmd, args)
					local out = vim.fn.systemlist(cmd)
					return out, vim.v.shell_error
				end

				local function escape_lua_pattern(text)
					return (text:gsub("([^%w])", "%%%1"))
				end

				local git_root = require("gitlinker.git").get_git_root()
				if not git_root then
					return
				end

				local remotes, remotes_code = git({ "remote" }, git_root)
				if remotes_code ~= 0 or remotes == nil or vim.tbl_isempty(remotes) then
					vim.notify("Git repo has no remote", vim.log.levels.ERROR)
					return
				end

				vim.ui.select(remotes, { prompt = "gitlinker: select remote" }, function(remote)
					if not remote or remote == "" then
						return
					end

					local function is_rev_in_remote(revspec)
						local branches, code = git({ "branch", "--remotes", "--contains", revspec }, git_root)
						if code ~= 0 then
							return false
						end
						local prefix = "^%s*" .. escape_lua_pattern(remote) .. "/"
						for _, rbranch in ipairs(branches) do
							if rbranch:match(prefix) then
								return true
							end
						end
						return false
					end

					local function get_remote_head_rev()
						local symref, symref_code =
							git({ "symbolic-ref", "refs/remotes/" .. remote .. "/HEAD" }, git_root)
						if symref_code == 0 and symref[1] then
							local ref = symref[1]:gsub("^refs/remotes/", "")
							local rev, rev_code = git({ "rev-parse", ref }, git_root)
							if rev_code == 0 and rev[1] then
								return rev[1]
							end
						end

						local rev, rev_code = git({ "rev-parse", remote .. "/HEAD" }, git_root)
						if rev_code == 0 and rev[1] then
							return rev[1]
						end

						local rev2, rev2_code = git({ "rev-parse", remote }, git_root)
						if rev2_code == 0 and rev2[1] then
							return rev2[1]
						end

						return nil
					end

					local function get_closest_remote_compatible_rev(max_depth)
						max_depth = max_depth or 50

						if is_rev_in_remote("HEAD") then
							local rev, code = git({ "rev-parse", "HEAD" }, git_root)
							if code == 0 and rev[1] then
								return rev[1]
							end
						end

						for i = 1, max_depth do
							local revspec = "HEAD~" .. i
							if is_rev_in_remote(revspec) then
								local rev, code = git({ "rev-parse", revspec }, git_root)
								if code == 0 and rev[1] then
									return rev[1]
								end
							end
						end

						return get_remote_head_rev()
					end

					local repo_url_data = require("gitlinker.git").get_repo_data(remote)
					if not repo_url_data then
						return
					end

					local rev = get_closest_remote_compatible_rev()
					if not rev then
						vim.notify(
							string.format("Failed to find a revision in remote '%s'", remote),
							vim.log.levels.ERROR
						)
						return
					end

					local buffer = require("gitlinker.buffer")
					local file = buffer.get_relative_path(git_root)
					local range = { lstart = buffer.get_curr_line() }

					local url_data = vim.tbl_extend("force", repo_url_data, {
						rev = rev,
						file = file,
						lstart = range.lstart,
					})

					local matching_callback = require("gitlinker.hosts").get_matching_callback(url_data.host)
					if not matching_callback then
						return
					end

					local url = matching_callback(url_data)
					actions.copy_to_clipboard(url)
					vim.notify(url)
				end)
			end,
			desc = "Copy git permalink (choose remote)",
		},
	},
}
