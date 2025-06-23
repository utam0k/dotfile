-- Testing framework
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest-go",
    "rouge8/neotest-rust",
    "nvim-neotest/neotest-jest",
  },
  ft = { "go", "rust", "javascript", "typescript", "javascriptreact", "typescriptreact" },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-go")({
          experimental = {
            test_table = true,
          },
        }),
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
      summary = {
        follow = true,
        expand_errors = true,
      },
    })

    -- Keymaps
    local map = function(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.noremap = opts.noremap ~= false
      opts.silent = opts.silent ~= false
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Leader keymaps
    map("n", "<leader>tr", function()
      require("neotest").run.run()
    end, { desc = "Run nearest test" })
    map("n", "<leader>tf", function()
      require("neotest").run.run(vim.fn.expand("%"))
    end, { desc = "Run file tests" })
    map("n", "<leader>ts", function()
      require("neotest").summary.toggle()
    end, { desc = "Toggle test summary" })
    map("n", "<leader>to", function()
      require("neotest").output.open({ enter = true })
    end, { desc = "Show test output" })

    -- Short keymaps
    map("n", "tr", function()
      require("neotest").run.run()
    end, { desc = "Run nearest test" })
    map("n", "tf", function()
      require("neotest").run.run(vim.fn.expand("%"))
    end, { desc = "Run file tests" })
    map("n", "ts", function()
      require("neotest").summary.toggle({ focus_file = vim.fn.expand("%:p") })
    end, { desc = "Toggle test summary for current file" })
    map("n", "to", function()
      require("neotest").output.open({ enter = true })
    end, { desc = "Show test output" })
    
    -- Additional test commands
    map("n", "<leader>tS", function()
      require("neotest").summary.toggle()
    end, { desc = "Toggle test summary (all files)" })
    
    -- gotestsel specific commands
    map("n", "<leader>tl", "<cmd>!gotestsel -l %<cr>", { desc = "List tests in file" })
    map("n", "<leader>ti", "<cmd>!gotestsel -t<cr>", { desc = "Interactive test selection" })
  end,
}