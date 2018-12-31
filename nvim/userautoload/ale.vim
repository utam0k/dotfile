let g:ale_lint_on_text_changed = 1

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

let g:ale_set_loclist = 0
let g:ale_set_quickfix = 0
let g:ale_fix_on_save = 1

let g:ale_fixers = {
    \ 'python': ['autopep8', 'black', 'isort'],
    \ }
let g:ale_linters = {
    \ 'python': ['flake8', 'mypy'],
    \ }

""" Python
let g:ale_python_mypy_executable = '--ignore-missing-imports'
let g:ale_python_flake8_executable = $HOME . '/.pyenv/shims/python'
let g:ale_python_flake8_options = '-m flake8'
let g:ale_python_autopep8_executable = g:python3_host_prog
let g:ale_python_autopep8_options = '-m autopep8'
let g:ale_python_isort_executable = g:python3_host_prog
let g:ale_python_isort_options = '-m isort'
let g:ale_python_black_executable = g:python3_host_prog
let g:ale_python_black_options = '-m black'
