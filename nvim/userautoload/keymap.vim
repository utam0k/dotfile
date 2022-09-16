set backspace=indent,eol,start

imap <C-J> <ESC>
nmap ; :

for n in range(1, 9)
  execute 'nnoremap z'.n 'zt'.n.'<C-Y>'
endfor

noremap <Space>h  ^
noremap <Space>l  $
noremap <Space>/  *
noremap <Space>m  %

noremap <C-J><C-J> :noh<CR>

let g:ctrlp_map = '<C-p>'

" imap <C-n> <Down>
" imap <C-b> <BS>
imap <C-l> <Right>
imap <C-h> <Left>

noremap tt :tabnew<CR>:terminal<CR>
