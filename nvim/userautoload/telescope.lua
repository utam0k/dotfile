local status, telescope = pcall(require, "telescope")
if (not status) then return end

local builtin = require('telescope.builtin')

telescope.setup({
  defaults = {
    sorting_strategy = "ascending",
    winblend = 4,
    layout_strategy = 'vertical',
    layout_config = { height = 0.9 },
    file_ignore_patterns = {
      "^.git/",
      "^node_modules/",
    },
    preview = {
      treesitter = false
    }
  },
  extensions = {
    coc = {
      prefer_locations = false,   
    }
  },
})

telescope.load_extension('vim_bookmarks', 'smart_open')

vim.keymap.set('n', '<C-p>', "<cmd>Telescope smart_open<cr>", { silent = true })

vim.keymap.set('n', '<C-g>',
  function()
    builtin.live_grep({
      no_ignore = false,
      hidden = true
    })
  end
)

local builtin = require('telescope.builtin')
vim.keymap.set('n', 'gd', builtin.lsp_definitions,     { desc = 'Go to definition' })
vim.keymap.set('n', 'gr', builtin.lsp_references,      { desc = 'References' })
vim.keymap.set('n', 'gi', builtin.lsp_implementations, { desc = 'Implementations' })
vim.keymap.set('n', '<leader>D', builtin.lsp_type_definitions, { desc = 'Type definition' })
vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, { desc = 'Document symbols' })
vim.keymap.set('n', '<leader>ws', builtin.lsp_dynamic_workspace_symbols, { desc = 'Workspace symbols' })

vim.keymap.set('n', 'di', function()
  builtin.diagnostics({bufnr = 0, severity_limit = vim.diagnostic.severity.HINT})
end, {desc='Workspace diagnostics'})
