let g:lightline = {
\   'colorscheme': 'solarized',
\   'active': {
\     'left': [['mode', 'paste'], ['cocstatus', 'fugitive', 'filename', 'watchdogs']],
\     'right':[[ 'filetype', 'fileencoding', 'lineinfo', 'percent' ]],
\   },
\   'component_function': {
\     'modified':     'LightLineModified',
\     'readonly':     'LightLineReadonly',
\     'fugitive':     'LightLineFugitive',
\     'filename':     'LightLineFilename',
\     'fileformat':   'LightLineFileformat',
\     'filetype':     'LightLineFiletype',
\     'fileencoding': 'LightLineFileencoding',
\     'mode':         'LightLineMode',
\     'cocstatus': 'StatusDiagnostic',
\   },
\   'component_expand': {
\     'watchdogs': 'qfstatusline#Update',
\   },
\   'component_type': {
\     'watchdogs': 'error',
\   },
\ }

function! LightLineModified()
  return &ft =~ 'help\|nerdtree\|undotree\|diff\|qf' ? '' : @% == '[YankRing]' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &ft !~? 'help\|nerdtree\|undotree\|diff' && &readonly ? '!' : ''
endfunction

function! LightLineFilename()
  return &ft == 'nerdtree' ? 'NERDTree' :
       \ &ft == 'undotree' ? 'undotree' :
       \ &ft == 'diff' ? 'diffpanel' :
       \ &ft == 'qf' ? 'Quickfix' :
       \ &ft == 'vimshell' ? vimshell#get_status_string() :
       \ @% == '[YankRing]' ? 'YankRing' :
       \ ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
       \ ('' != @% ? @% : '[No Name]') .
       \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFugitive()
  if &ft !~? 'help\|nerdtree\|undotree\|quickrun\|qf' && @% != '[YankRing]' && exists("*fugitive#head")
    let _ = fugitive#head()
    return strlen(_) ? ' ○ '._ : ''
  endif
  return ''
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
  return &ft == 'qf' ? '' :
       \ @% == '[YankRing]' ? '' :
       \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

let g:vimshell_force_overwrite_statusline = 0
autocmd CursorMoved ControlP let w:lightline = 0

function! CocCurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction

function! StatusDiagnostic() abort
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) | return '' | endif
  let msgs = []
  if get(info, 'error', 0)
    call add(msgs, 'E' . info['error'])
  endif
  if get(info, 'warning', 0)
    call add(msgs, 'W' . info['warning'])
  endif

  return join(msgs, ''). '' . get(g:, 'coc_status', '')
endfunction

function! LightlineGitBlame() abort
  let blame = get(b:, 'coc_git_blame', '')
  " return blame
  return winwidth(0) > 120 ? blame : ''
endfunction
