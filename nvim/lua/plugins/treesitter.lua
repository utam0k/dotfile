-- Treesitter configuration
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "c", "lua", "vim", "go", "rust", "python", "javascript", "typescript", "yaml", "json", "toml" },
      auto_install = true,
      highlight = {
        enable = true,
        disable = {
          "lua",
          "ruby",
          "toml",
          "c_sharp",
          "vue",
        },
      },
      indent = {
        enable = true,
      },
    })
  end,
}