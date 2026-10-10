-- Testing framework
return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-neotest/nvim-nio",
		"williamboman/mason.nvim", -- Add Mason's executables to PATH before checking runners.
		{ "fredrikaverpil/neotest-golang", branch = "main", version = "^2" },
		"rouge8/neotest-rust",
		"nvim-neotest/neotest-jest",
	},
	ft = { "go", "rust", "javascript", "typescript", "javascriptreact", "typescriptreact" },
	config = function()
		local function check_gotestsum()
			if vim.fn.executable("gotestsum") == 0 then
				vim.schedule(function()
					vim.notify_once(
						"Go live logs: install gotestsum with :MasonInstall gotestsum, then restart Neovim. "
							.. "Until then, attach shows raw JSON.",
						vim.log.levels.WARN
					)
				end)
			end
		end
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("neotest_gotestsum", { clear = true }),
			pattern = "go",
			once = true,
			callback = check_gotestsum,
		})
		if vim.bo.filetype == "go" then
			check_gotestsum()
		end

		require("neotest").setup({
			consumers = { test_gutter = require("config.test_gutter").init },
			-- Discover opened buffers; scanning a large repository and its worktrees
			-- at startup can overwhelm the parser subprocess and editor.
			discovery = { enabled = false, concurrent = 1 },
			adapters = {
				require("neotest-golang")({
					-- Keep attach output readable while Neotest reads a separate JSON file.
					runner = "gotestsum",
					gotestsum_args = { "--format=standard-verbose" },
					warn_test_name_dupes = false,
					-- Rerun selected cases without requiring CGO for the race detector.
					go_test_args = { "-v", "-count=1" },
				}),
				require("config.neotest_rust"),
				require("neotest-jest")({
					jestCommand = "npm test --",
					jestConfigFile = "jest.config.js",
					env = { CI = true },
					cwd = function(path)
						return vim.fn.getcwd()
					end,
				}),
			},
			icons = {
				test = "▶",
				passed = "✓",
				failed = "✗",
				running = "◷",
				skipped = "↷",
			},
			status = { signs = true, virtual_text = false },
			output = { open_on_run = false },
			summary = {
				follow = true,
				expand_errors = true,
			},
		})
		-- Dim only the gutter marker; summary test names keep their usual color.
		vim.fn.sign_define("neotest_test", { text = require("neotest.config").icons.test, texthl = "Comment" })

		-- Keymaps
		local map = function(mode, lhs, rhs, opts)
			opts = opts or {}
			opts.noremap = opts.noremap ~= false
			opts.silent = opts.silent ~= false
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- Leader keymaps
		map("n", "<leader>tr", function()
			require("neotest").run.run()
		end, { desc = "Run nearest test" })
		map("n", "<leader>tf", function()
			require("neotest").run.run(vim.fn.expand("%"))
		end, { desc = "Run file tests" })
		map("n", "<leader>ts", function()
			require("neotest").summary.toggle()
		end, { desc = "Toggle test summary" })
		map("n", "<leader>to", function()
			require("neotest").output.open({ enter = true })
		end, { desc = "Show test output" })

		-- Short keymaps
		map("n", "tr", function()
			require("neotest").run.run()
		end, { desc = "Run nearest test" })
		map("n", "tf", function()
			require("neotest").run.run(vim.fn.expand("%"))
		end, { desc = "Run file tests" })
		map("n", "ts", function()
			require("neotest").summary.toggle({ focus_file = vim.fn.expand("%:p") })
		end, { desc = "Toggle test summary for current file" })
		map("n", "to", function()
			require("neotest").output.open({ enter = true })
		end, { desc = "Show test output" })

		-- Additional test commands
		map("n", "<leader>tR", function()
			require("neotest").run.run_last()
		end, { desc = "Rerun last test" })
		map("n", "<leader>tx", function()
			require("neotest").run.stop()
		end, { desc = "Stop nearest test" })
		map("n", "<leader>tS", function()
			require("neotest").summary.toggle()
		end, { desc = "Toggle test summary (all files)" })

		-- gotestsel specific commands
		map("n", "<leader>tl", "<cmd>!gotestsel -l %<cr>", { desc = "List tests in file" })
		map("n", "<leader>ti", "<cmd>!gotestsel -t<cr>", { desc = "Interactive test selection" })
	end,
}
