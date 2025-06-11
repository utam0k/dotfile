-- Testing framework
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/nvim-nio",
    "fredrikaverpil/neotest-golang",
    "rouge8/neotest-rust",
    "nvim-neotest/neotest-jest",
  },
  ft = { "go", "rust", "javascript", "typescript", "javascriptreact", "typescriptreact" },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-golang"),
        require("neotest-rust"),
        require("neotest-jest")({
          jestCommand = "npm test --",
          jestConfigFile = "jest.config.js",
          env = { CI = true },
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        }),
      },
    })

    -- Keymaps
    local map = function(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.noremap = opts.noremap ~= false
      opts.silent = opts.silent ~= false
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map("n", "<leader>tr", function() require("neotest").run.run() end, { desc = "Run nearest test" })
    map("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run file tests" })
    map("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle test summary" })
    map("n", "<leader>to", function() require("neotest").output.open({ enter = true }) end, { desc = "Show test output" })
  end,
}
