-- Status line
return {
  "itchyny/lightline.vim",
  lazy = false,
  config = function()
    vim.g.lightline = {
      colorscheme = "solarized",
      active = {
        left = {
          { "mode", "paste" },
          { "fugitive", "filename", "modified" }
        },
        right = {
          { "filetype", "fileencoding", "lineinfo", "percent" }
        }
      },
      component_function = {
        modified = "LightLineModified",
        readonly = "LightLineReadonly",
        fugitive = "LightLineFugitive",
        filename = "LightLineFilename",
        fileformat = "LightLineFileformat",
        filetype = "LightLineFiletype",
        fileencoding = "LightLineFileencoding",
        mode = "LightLineMode",
      }
    }
    
    -- Define lightline functions
    vim.cmd([[
      function! LightLineModified()
        return &ft =~ 'help\|neo-tree\|oil' ? '' : &modified ? '+' : &modifiable ? '' : '-'
      endfunction
      
      function! LightLineReadonly()
        return &ft !~? 'help\|neo-tree\|oil' && &readonly ? '!' : ''
      endfunction
      
      function! LightLineFilename()
        return &ft == 'neo-tree' ? 'Neo-tree' :
             \ &ft == 'oil' ? 'Oil' :
             \ ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
             \ ('' != @% ? @% : '[No Name]') .
             \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
      endfunction
      
      function! LightLineFugitive()
        if &ft !~? 'help\|neo-tree\|oil' && exists("*fugitive#head")
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
        return winwidth(0) > 60 ? lightline#mode() : ''
      endfunction
    ]])
  end,
}