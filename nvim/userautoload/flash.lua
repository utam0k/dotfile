local Flash = require("flash")
vim.keymap.set("n", "s", function() Flash.jump({
    modes = {
        char = {
          enabled = true,
          keys = { "f", "F", "T", ";", "," },
        },
    }
}) end, { desc = "Flash" })
vim.keymap.set("n", "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
vim.keymap.set("o", "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
vim.keymap.set("c", "<c-s>", function() require("flash").toggle() end, { desc = "Treesitter Search" })
