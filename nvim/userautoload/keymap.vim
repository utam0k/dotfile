imap <C-J> <ESC>
nmap ; :

for n in range(1, 9)
  execute 'nnoremap z'.n 'zt'.n.'<C-Y>'
endfor

noremap <Space>h  ^
noremap <Space>l  $

noremap <C-J><C-J> :noh<CR>
