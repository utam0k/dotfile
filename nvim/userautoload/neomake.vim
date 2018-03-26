let g:neomake_error_sign = {'text': '>>', 'texthl': 'Error'}
let g:neomake_warning_sign = {'text': '>>',  'texthl': 'Todo'}
augroup my_neomake_cmds
    autocmd!
    " Have neomake run cargo when Rust files are saved.
    autocmd BufWritePost *.rs Neomake! cargo
augroup END
