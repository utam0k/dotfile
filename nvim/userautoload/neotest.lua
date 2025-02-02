local neotest_golang_opts = {}
require("neotest").setup({
    adapters = {
        require("neotest-golang")(neotest_golang_opts),
        require('neotest-rust'),
    },
     -- See all config options with :h neotest.Config
    discovery = {
        -- Drastically improve performance in ginormous projects by
        -- only AST-parsing the currently opened buffer.
        enabled = false,
        -- Number of workers to parse files concurrently.
        -- A value of 0 automatically assigns number based on CPU.
        -- Set to 1 if experiencing lag.
        concurrent = 1,
    },
    running = {
        -- Run tests concurrently when an adapter provides multiple commands to run.
        concurrent = true,
    },
    summary = {
        -- Enable/disable animation of icons.
        animated = false,
    },
})
vim.keymap.set("n", "ts", "<cmd>Neotest summary<cr>")
vim.keymap.set("n", "to", "<cmd>Neotest output<cr>")
vim.keymap.set("n", "tr", "<cmd>Neotest run<cr>")
