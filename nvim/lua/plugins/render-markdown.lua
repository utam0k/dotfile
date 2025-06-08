-- Render markdown in Neovim
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.nvim", -- For icons support
  },
  ft = { "markdown", "vimwiki" }, -- Lazy load on markdown files
  keys = {
    { "<leader>rm", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle render markdown" },
  },
  opts = {
    enabled = true,
    render_modes = { 'n', 'v', 'i', 'c' },
    max_file_size = 10.0,
    file_types = { 'markdown', 'vimwiki' },
    -- Code blocks
    code = {
      enabled = true,
      sign = true,
      style = 'full',
      position = 'left',
      language_pad = 0,
      width = 'full',
      left_pad = 0,
      right_pad = 0,
      min_width = 0,
      border = 'thin',
      above = '▄',
      below = '▀',
      highlight = 'RenderMarkdownCode',
      highlight_inline = 'RenderMarkdownCodeInline',
    },
    -- Headings
    heading = {
      enabled = true,
      sign = true,
      position = 'overlay',
      icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
      signs = { '󰫎 ' },
      width = 'full',
      left_pad = 0,
      right_pad = 0,
      min_width = 0,
      border = false,
      border_prefix = false,
      above = '▄',
      below = '▀',
      backgrounds = {
        'RenderMarkdownH1Bg',
        'RenderMarkdownH2Bg',
        'RenderMarkdownH3Bg',
        'RenderMarkdownH4Bg',
        'RenderMarkdownH5Bg',
        'RenderMarkdownH6Bg',
      },
      foregrounds = {
        'RenderMarkdownH1',
        'RenderMarkdownH2',
        'RenderMarkdownH3',
        'RenderMarkdownH4',
        'RenderMarkdownH5',
        'RenderMarkdownH6',
      },
    },
    -- Lists
    bullet = {
      enabled = true,
      icons = { '●', '○', '◆', '◇' },
      left_pad = 0,
      right_pad = 0,
      highlight = 'RenderMarkdownBullet',
    },
    checkbox = {
      enabled = true,
      unchecked = {
        icon = '󰄱 ',
        highlight = 'RenderMarkdownUnchecked',
      },
      checked = {
        icon = '󰱒 ',
        highlight = 'RenderMarkdownChecked',
      },
      custom = {
        todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
      },
    },
    -- Tables
    table = {
      enabled = true,
      style = 'full',
      cell_style = 'overlay',
      mimic_vimwiki_align = true,
      head = 'RenderMarkdownTableHead',
      row = 'RenderMarkdownTableRow',
      filler = 'RenderMarkdownTableFill',
    },
    -- Links
    link = {
      enabled = true,
      hyperlink = '󰌹 ',
      highlight = 'RenderMarkdownLink',
    },
  },
  config = function(_, opts)
    require('render-markdown').setup(opts)
  end,
}