require("no-neck-pain").setup({
    width = 300,
    autocmds = { enableOnVimEnter = true, enableOnTabEnter = false },
    buffers = {
        wo = {
            fillchars = "eob: ",
        },
    },
})

