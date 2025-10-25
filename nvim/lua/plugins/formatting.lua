-- Formatting configuration using conform.nvim
--
-- KEY FEATURES:
-- - \f: Format buffer or selection (normal/visual mode)
-- - :FormatDisable!: Disable auto-format for current buffer only
-- - :FormatDisable: Disable auto-format globally
-- - :FormatEnable: Re-enable auto-format
--
-- OSS CONTRIBUTION NOTES:
-- - Go: Run goimports first, then gofmt -s for stable formatting
-- - Go: Async formatting won't block save on syntax errors
-- - Visual mode: Format only selected lines for partial edits
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"\\f",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = { "n", "v" },
			desc = "Format buffer or selection",
		},
	},
	opts = {
		-- Define formatters per filetype
		formatters_by_ft = {
			-- Go: goimports handles imports, gofmt -s polishes syntax
			go = { "goimports", "gofmt" },

			-- Rust
			rust = { "rustfmt" },

			-- Python
			python = { "ruff_format", "ruff_fix" },

			-- JavaScript/TypeScript
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },

			-- Web formats
			html = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },

			-- Lua
			lua = { "stylua" },

			-- YAML (disabled)
			-- yaml = { "prettier" },

			-- Markdown
			markdown = { "prettier" },
			["markdown.mdx"] = { "prettier" },

			-- Shell scripts
			sh = { "shfmt" },
			bash = { "shfmt" },
			zsh = { "shfmt" },

			-- TOML
			toml = { "taplo" },

			-- Terraform
			terraform = { "terraform_fmt" },
			tf = { "terraform_fmt" },
			["terraform-vars"] = { "terraform_fmt" },

			-- C/C++
			c = { "clang_format" },
			cpp = { "clang_format" },

			-- Default formatter for all filetypes
			["_"] = { "trim_whitespace" },
		},

		-- Format on save configuration (synchronous)
		format_on_save = function(bufnr)
			-- Disable with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			-- Disable synchronous formatting for these filetypes
			local disable_filetypes = {
				"sql", -- Often has large files
				"java", -- Handled by LSP
				"go", -- Uses async format_after_save instead
			}
			if vim.tbl_contains(disable_filetypes, vim.bo[bufnr].filetype) then
				return
			end

			return {
				timeout_ms = 1000,
				lsp_fallback = true,
			}
		end,

		-- Format after save configuration (asynchronous, for Go)
		format_after_save = function(bufnr)
			-- Disable with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			-- Only format Go files after save (async)
			if vim.bo[bufnr].filetype == "go" then
				return {
					timeout_ms = 1000,
					lsp_fallback = false,
					quiet = true, -- Don't show errors for syntax issues
				}
			end
		end,

		-- Formatter configurations
		formatters = {
			gofmt = {
				prepend_args = { "-s" }, -- Simplify code
			},
			goimports = {
				-- Default settings keep imports tidy
			},
			clang_format = {
				prepend_args = { "--style=file" },
			},
			shfmt = {
				prepend_args = {
					"-i",
					"2", -- 2 space indent
					"-ci", -- Indent case labels
				},
			},
			stylua = {
				prepend_args = {
					"--indent-type",
					"Spaces",
					"--indent-width",
					"2",
				},
			},
			prettier = {
				prepend_args = { "--tab-width", "2" },
			},
			ruff_format = {
				prepend_args = { "--line-length", "88" }, -- Python standard
			},
			ruff_fix = {
				prepend_args = {
					"--select",
					"I", -- Select import sorting rules
					"--fix", -- Apply fixes
				},
			},
		},
	},
	init = function()
		-- Formatting error notifications (mainly for Go async formatting)
		vim.api.nvim_create_autocmd("User", {
			pattern = "FormatterPost",
			callback = function(args)
				if args.data and args.data.errored and vim.bo.filetype == "go" then
					vim.notify("Go formatting failed (syntax error?)", vim.log.levels.WARN)
				end
			end,
		})

		-- User commands for toggling autoformat
		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				-- FormatDisable! will disable formatting just for this buffer
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
		end, {
			desc = "Disable autoformat on save",
			bang = true,
		})

		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, {
			desc = "Re-enable autoformat on save",
		})

		-- Show formatter info
		vim.api.nvim_create_user_command("FormatInfo", function()
			vim.cmd("ConformInfo")
		end, {
			desc = "Show formatter info for current buffer",
		})
	end,
}
