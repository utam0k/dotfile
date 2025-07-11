-- GitHub Copilot
return {
  "github/copilot.vim",
  event = "VeryLazy", -- Load earlier to ensure it's ready
  config = function()
    -- Disable default Tab mapping to avoid conflicts
    vim.g.copilot_no_tab_map = true
    
    -- Enable Copilot on startup
    vim.g.copilot_enabled = true
    
    -- Commands for manual control
    vim.api.nvim_create_user_command("CopilotToggle", function()
      vim.cmd("Copilot toggle")
    end, {})
  end,
}
