-- Claude Code integration
return {
  "greggh/claude-code.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "ClaudeCode", "ClaudeCodeChat" },
  config = function()
    -- Claude Code configuration can be added here if needed
  end,
}