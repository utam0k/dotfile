nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-f> <cmd>Telescope frecency<cr>
nnoremap <C-g> <cmd>Telescope live_grep<cr>

lua << EOF
    require('telescope').load_extension('frecency')
EOF
