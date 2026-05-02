-- Mason configuration for LSP server management
return {
	"williamboman/mason.nvim",
	build = ":MasonUpdate",
	cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
	-- Loaded transitively as a dependency of lspconfig (BufReadPre) and
	-- mason-tool-installer (VeryLazy), so explicit lazy=false is unnecessary.
	config = function()
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})
	end,
}
