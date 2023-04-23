lua << EOF
    -- disable netrw at the very start of your init.lua (strongly advised)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- set termguicolors to enable highlight groups
    vim.opt.termguicolors = true

    require("nvim-tree").setup{
        diagnostics = {
            enable = true,
            show_on_dirs = true,
         },
         update_focused_file = {
            enable = true,
            update_root = true,
         },
    }
    require("nvim-web-devicons").setup {
        color_icons = true;
        -- globally enable default icons (default to false)
        -- will get overriden by `get_icons` option
        default = true;
        -- globally enable "strict" selection of icons - icon will be looked up in
        -- different tables, first by filename, and if not found by extension; this
        -- prevents cases when file doesn't have any extension but still gets some icon
        -- because its name happened to match some extension (default to false)
        strict = true;
    }
EOF

nmap <silent> <Space>e :NvimTreeToggle<CR>
