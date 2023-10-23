nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-g> <cmd>Telescope live_grep<cr>
lua << EOF
    require('telescope').load_extension('vim_bookmarks')
EOF
