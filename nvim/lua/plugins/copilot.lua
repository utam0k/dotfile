-- GitHub Copilot
return {
  "github/copilot.vim",
  event = "VeryLazy", -- Load earlier to ensure it's ready
  config = function()
    -- Enable Copilot on startup
    vim.g.copilot_enabled = true
    
    -- Commands for manual control
    vim.api.nvim_create_user_command("CopilotToggle", function()
      vim.cmd("Copilot toggle")
    end, {})
  end,
}
