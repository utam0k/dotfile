-- Debug Adapter Protocol setup for Go (and general keymaps)
return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "DAP: Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP: Continue/Start" },
      { "<leader>di", function() require("dap").step_into() end, desc = "DAP: Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "DAP: Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "DAP: Step out" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "DAP: Toggle REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "DAP: Run last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "DAP: Terminate" },
    },
    config = function()
      local dap = require("dap")

      -- Use subtle signs for breakpoints/stopped state
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError" })
      vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticSignInfo" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticSignWarn" })
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap_go = require("dap-go")
      dap_go.setup({
        delve = {
          detached = vim.fn.has("win32") == 0,
        },
      })

      -- Go-specific helpers
      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = desc })
      end

      map("<leader>dgt", function()
        dap_go.debug_test()
      end, "DAP Go: Debug nearest test")

      map("<leader>dgl", function()
        dap_go.debug_last()
      end, "DAP Go: Debug last test")
    end,
  },
}
