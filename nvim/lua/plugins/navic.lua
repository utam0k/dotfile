-- nvim-navic: Shows current code context in statusline/winbar
return {
  "SmiteshP/nvim-navic",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  event = "LspAttach",
  config = function()
    local navic = require("nvim-navic")
    
    navic.setup({
      icons = {
        File = " ",
        Module = " ",
        Namespace = " ",
        Package = " ",
        Class = " ",
        Method = " ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = " ",
        Interface = " ",
        Function = " ",
        Variable = " ",
        Constant = " ",
        String = " ",
        Number = " ",
        Boolean = " ",
        Array = " ",
        Object = " ",
        Key = " ",
        Null = " ",
        EnumMember = " ",
        Struct = " ",
        Event = " ",
        Operator = " ",
        TypeParameter = " ",
      },
      lsp = {
        auto_attach = true,
        preference = {
          "gopls",
          "rust_analyzer", 
          "lua_ls",
          "pyright",
          "terraformls",
          "yamlls",
        },
      },
      highlight = true,
      separator = " > ",
      depth_limit = 4,
      depth_limit_indicator = "..",
      safe_output = true,
      lazy_update_context = false,
      click = false,
    })
  end,
}