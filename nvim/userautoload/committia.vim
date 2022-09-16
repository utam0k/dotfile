" let g:committia_hooks = {}
" function! g:committia_hooks.edit_open(info)
"     " Additional settings
"     setlocal spell
"
"     " If no commit message, start with insert mode
"     if a:info.vcs ==# 'git' && getline(1) ==# ''
"         startinsert
"     end
"
"     " Scroll the diff window from insert mode
"     " Map <C-n> and <C-p>
"     imap <buffer><C-n> <Plug>(committia-scroll-diff-down-half)
"     nmap <buffer><C-n> <Plug>(committia-scroll-diff-down-half)
"     imap <buffer><C-p> <Plug>(committia-scroll-diff-up-half)
"     nmap <buffer><C-p> <Plug>(committia-scroll-diff-up-half)
"     imap <buffer><C-u> <Plug>(committia-scroll-diff-down-half)
"     nmap <buffer><C-u> <Plug>(committia-scroll-diff-down-half)
"     imap <buffer><C-d> <Plug>(committia-scroll-diff-up-half)
"     nmap <buffer><C-d> <Plug>(committia-scroll-diff-up-half)
"
" endfunction
