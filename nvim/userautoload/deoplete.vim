let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#syntax#min_keyword_length = 2

autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns = {}
endif

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
