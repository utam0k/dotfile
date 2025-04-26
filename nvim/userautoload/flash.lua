require('flash').setup({
    jump  = { autojump = true },

    label = {
        rainbow = { enabled = true },
        uppercase = false ,
        keys='arstneioqwfpjluy;zxcvbnm'
    },
    search = {
        case = "ignore_case",
    },
    modes = {
        search = {
            enabled = true,
            jump = { autojump = true },
            case = "ignore_case",
        },
        char   = { jump_labels = true, multi_line = false },
    },
})

local flash = require('flash')
local map   = vim.keymap.set

map('n', 's', flash.jump,       { desc = 'Flash Jump' })
map('n', 'S', flash.remote,     { desc = 'Flash Remote Jump' })

map('n', '<leader>fs', flash.toggle, { desc = 'Flash Toggle Search' })

map('n', '<leader>ff', function()
    require('telescope.builtin').find_files()
    flash.search({ highlight = false })
end, { desc = 'Telescope + Flash' })

