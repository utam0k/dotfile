-- Testing framework
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/nvim-nio",
    "fredrikaverpil/neotest-golang",
    "rouge8/neotest-rust",
  },
  ft = { "go", "rust" },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-golang"),
        require("neotest-rust"),
      },
    })
  end,
}
