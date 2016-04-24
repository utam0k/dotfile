let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable =1
let g:unite_source_file_mru_limit = 200
nnoremap <silent> <Space>y :Unite history/yank -no-start-insert<CR>
nnoremap <silent> <Space>b :Unite buffer -no-start-insert<CR>
nnoremap <silent> <Space>r :Unite -buffer-name=register register -no-start-insert<CR>
nnoremap <silent> <Space>p :Unite file_rec/async:!<CR>
