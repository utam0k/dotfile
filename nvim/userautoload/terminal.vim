tnoremap <silent> <ESC> <C-\><C-n>
tnoremap <silent> <C-]> <C-\><C-n>

for n in range(1, 9)
  execute 'tnoremap t'.n  '<C-\><C-n>:<C-u>tabnext'.n.'<CR>'
endfor
