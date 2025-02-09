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

telescope.load_extension('vim_bookmarks', 'coc', 'smart_open')

-- vim.keymap.set('n', '<C-p>',
--   function()
--     builtin.find_files({
--       no_ignore = false,
--       hidden = true
--     })
--   end
-- )
vim.keymap.set('n', '<C-p>', "<cmd>Telescope smart_open<cr>", { silent = true })

vim.keymap.set('n', '<C-g>',
  function()
    builtin.live_grep({
      no_ignore = false,
      hidden = true
    })
  end
)

vim.keymap.set("n", "gd", "<cmd>Telescope coc definitions<cr>", { silent = true })
-- vim.keymap.set("n", "gs", "<cmd>Telescope coc definitions<cr>", { silent = true })
vim.keymap.set("n", "gr", "<cmd>Telescope coc references<cr>", { silent = true })
vim.keymap.set("n", "gy", "<cmd>Telescope coc type_definitions<cr>", { silent = true })
vim.keymap.set("n", "gi", "<cmd>Telescope coc implementations<cr>", { silent = true })
vim.keymap.set("n", "di", "<cmd>Telescope coc diagnostics<cr>", { silent = true })
vim.keymap.set("n", "ds", "<cmd>Telescope coc document_symbols<cr>", { silent = true })
