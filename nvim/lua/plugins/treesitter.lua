-- Treesitter configuration (main branch — Neovim 0.11+ idiom)
-- master is archived; main is the rewrite. After :Lazy sync the build
-- runs :TSUpdate; parsers listed below are also installed at config time.
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local ensure = {
			"c",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"go",
			"rust",
			"python",
			"javascript",
			"typescript",
			"yaml",
			"json",
			"toml",
			"markdown",
			"markdown_inline",
		}

		-- Install missing parsers asynchronously (idempotent).
		require("nvim-treesitter").install(ensure)

		-- Filetypes that should keep the legacy syntax engine.
		local highlight_disable = { ruby = true, c_sharp = true, vue = true }

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
			callback = function(args)
				if highlight_disable[args.match] then
					return
				end

				-- Silent no-op when no parser is installed for this filetype.
				if not pcall(vim.treesitter.start, args.buf) then
					return
				end

				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
