-- Miscellaneous plugins
return {
  -- Tagbar (consider replacing with a Treesitter-based alternative)
  {
    "majutsushi/tagbar",
    cmd = "TagbarToggle",
    keys = {
      { "<F8>", "<cmd>TagbarToggle<cr>", desc = "Toggle Tagbar" },
    },
  },
  -- Schema store for JSON/YAML
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
  -- Fix cursor hold
  {
    "antoinemadec/FixCursorHold.nvim",
    event = "VeryLazy",
  },
}