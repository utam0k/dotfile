require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "go", "rust" },
  auto_install = true,
  highlight = {
    enable = true,
    disable = {
      'lua',
      'ruby',
      'toml',
      'c_sharp',
      'vue',
    }
  },
  indent = {
    enable = true,
  }
}
