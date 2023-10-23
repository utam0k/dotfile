set t_Co=256

set mouse=

set cursorline
augroup CursorLineOnlyCurrentWindow
  autocmd!
  autocmd WinLeave * set nocursorline
  autocmd WinEnter,BufRead * set cursorline
augroup END

set background=dark
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox
if (empty($TMUX) && getenv('TERM_PROGRAM') != 'Apple_Terminal')
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

set laststatus=2

set list
set listchars=tab:>-

set number
set colorcolumn=100

augroup AdditionalHighlights
  autocmd!

  autocmd ColorScheme * highlight TrailingSpaces term=NONE ctermbg=Red
  autocmd Syntax * syntax match TrailingSpaces containedin=ALL /\s\+$/

  autocmd ColorScheme * highlight FullWidthSpace term=NONE ctermbg=Red
  autocmd Syntax * syntax match FullWidthSpace containedin=ALL /　/
augroup END

syntax on
