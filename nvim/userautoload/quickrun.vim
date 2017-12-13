let g:quickrun_config = {
\   '_': {
\     'hook/time/enable': 1,
\     'runner': 'vimproc',
\     'runner/vimproc/updatetime': 60,
\     'outputter/buffer/split': ':vertical 50',
\   },
\   'bundle' : {
\     'type': 'bundle',
\     'command': 'ruby',
\     'exec': 'bundle exec %c %s',
\   },
\ }

nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
nnoremap qr :QuickRun<CR>
" \     'outputter/buffer/split': ':botright 8',
