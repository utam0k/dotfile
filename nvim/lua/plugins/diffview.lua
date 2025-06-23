-- Git diff viewer
return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
	config = function()
		require("diffview").setup({
			diff_binaries = false, -- Show diffs for binaries
			enhanced_diff_hl = true, -- Enhanced diff highlighting
			git_cmd = { "git" }, -- Git executable path
			hg_cmd = { "hg" }, -- Mercurial executable path
			use_icons = true, -- Use icons for files/folders
			show_help_hints = false, -- Show help hints in the file panel
			watch_index = true, -- Update views when the git index changes
			view = {
				-- Configure the layout and behavior of different types of views
				default = {
					-- Config for changed files, and staged files in diff views
					layout = "diff2_horizontal",
					winbar_info = false, -- Show file path in winbar
				},
				merge_tool = {
					-- Config for merge tool views
					layout = "diff3_horizontal", -- Show base, local, and remote
					disable_diagnostics = true, -- Disable diagnostics during merge
					winbar_info = true,
				},
				file_history = {
					-- Config for file history views
					layout = "diff2_horizontal",
					winbar_info = false,
				},
			},
			file_panel = {
				listing_style = "list", -- "list" or "tree"
				tree_options = {
					flatten_dirs = true, -- Flatten dirs with only one child
					folder_statuses = "only_folded", -- "never", "only_folded", "always"
				},
				win_config = {
					position = "left",
					width = 45,
					win_opts = {},
				},
			},
			file_history_panel = {
				log_options = {
					git = {
						single_file = {
							diff_merges = "combined",
						},
						multi_file = {
							diff_merges = "first-parent",
						},
					},
				},
				win_config = {
					position = "bottom",
					height = 16,
					win_opts = {},
				},
			},
			commit_log_panel = {
				win_config = {
					win_opts = {},
				},
			},
			default_args = {
				DiffviewOpen = {},
				DiffviewFileHistory = {},
			},
			hooks = {
				diff_buf_read = function(bufnr)
					-- Disable diagnostics for diff buffers to reduce noise
					vim.diagnostic.disable(bufnr)
				end,
			},
			keymaps = {
				disable_defaults = false,
				view = {
					-- Enhanced navigation in diff view
					{ "n", "<tab>", "<cmd>DiffviewToggleFiles<CR>", { desc = "Toggle file panel" } },
					{ "n", "g<C-x>", "<cmd>DiffviewToggleFiles<CR>", { desc = "Toggle file panel" } },
					{ "n", "gf", require("diffview.actions").goto_file_edit, { desc = "Open file" } },
					{ "n", "<C-w><C-f>", require("diffview.actions").goto_file_split, { desc = "Open file in split" } },
					{ "n", "<C-w>gf", require("diffview.actions").goto_file_tab, { desc = "Open file in tab" } },
				},
				file_panel = {
					{ "n", "j", require("diffview.actions").next_entry, { desc = "Next entry" } },
					{ "n", "<down>", require("diffview.actions").next_entry, { desc = "Next entry" } },
					{ "n", "k", require("diffview.actions").prev_entry, { desc = "Previous entry" } },
					{ "n", "<up>", require("diffview.actions").prev_entry, { desc = "Previous entry" } },
					{ "n", "<cr>", require("diffview.actions").select_entry, { desc = "Select entry" } },
					{ "n", "o", require("diffview.actions").select_entry, { desc = "Select entry" } },
					{ "n", "<2-LeftMouse>", require("diffview.actions").select_entry, { desc = "Select entry" } },
					{ "n", "s", require("diffview.actions").toggle_stage_entry, { desc = "Stage/unstage entry" } },
					{ "n", "S", require("diffview.actions").stage_all, { desc = "Stage all entries" } },
					{ "n", "U", require("diffview.actions").unstage_all, { desc = "Unstage all entries" } },
					{ "n", "X", require("diffview.actions").restore_entry, { desc = "Restore entry" } },
					{ "n", "L", require("diffview.actions").open_commit_log, { desc = "Open commit log" } },
				},
				file_history_panel = {
					{ "n", "g!", require("diffview.actions").options, { desc = "Open options" } },
					{ "n", "<C-A-d>", require("diffview.actions").open_in_diffview, { desc = "Open in diffview" } },
					{ "n", "y", require("diffview.actions").copy_hash, { desc = "Copy commit hash" } },
					{ "n", "L", require("diffview.actions").open_commit_log, { desc = "Open commit log" } },
					{ "n", "zR", require("diffview.actions").open_all_folds, { desc = "Open all folds" } },
					{ "n", "zM", require("diffview.actions").close_all_folds, { desc = "Close all folds" } },
					{ "n", "j", require("diffview.actions").next_entry, { desc = "Next entry" } },
					{ "n", "<down>", require("diffview.actions").next_entry, { desc = "Next entry" } },
					{ "n", "k", require("diffview.actions").prev_entry, { desc = "Previous entry" } },
					{ "n", "<up>", require("diffview.actions").prev_entry, { desc = "Previous entry" } },
					{ "n", "<cr>", require("diffview.actions").select_entry, { desc = "Select entry" } },
					{ "n", "o", require("diffview.actions").select_entry, { desc = "Select entry" } },
					{ "n", "<2-LeftMouse>", require("diffview.actions").select_entry, { desc = "Select entry" } },
				},
			},
		})
	end,
}
