-- Tabby.nvim: Highly customizable tabline
return {
  "nanozuki/tabby.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
  },
  event = "VimEnter",
  config = function()
    local theme = {
      fill = "TabLineFill",
      head = "TabLineFill",
      current_tab = "TabLineSel",
      tab = "TabLine",
      win = "TabLine",
      tail = "TabLineFill",
    }
    
    -- Get git diff status
    local function get_git_status(bufnr)
      local ok, signs = pcall(vim.api.nvim_buf_get_var, bufnr, "gitsigns_status_dict")
      if not ok or not signs then
        return nil
      end
      
      local added = signs.added or 0
      local changed = signs.changed or 0
      local removed = signs.removed or 0
      
      if added > 0 or changed > 0 or removed > 0 then
        return {
          added = added,
          changed = changed,
          removed = removed,
          has_changes = true
        }
      end
      
      return nil
    end
    
    -- Get diagnostics count
    local function get_diagnostics(bufnr)
      local diagnostics = vim.diagnostic.get(bufnr)
      local count = { error = 0, warn = 0 }
      
      for _, diagnostic in ipairs(diagnostics) do
        if diagnostic.severity == vim.diagnostic.severity.ERROR then
          count.error = count.error + 1
        elseif diagnostic.severity == vim.diagnostic.severity.WARN then
          count.warn = count.warn + 1
        end
      end
      
      return count
    end
    
    -- Calculate tab width based on content and window width
    local function calculate_tab_width(max_content_width)
      local total_width = vim.o.columns
      local num_tabs = vim.fn.tabpagenr('$')
      
      -- Constraints
      local min_tab_width = 15
      local max_tab_width = 50
      
      -- Calculate equal width for each tab
      local equal_width = math.floor(total_width / num_tabs)
      
      -- Use the smaller of: equal distribution, max content width, or max limit
      local optimal_width = math.min(equal_width, max_content_width + 4, max_tab_width)
      
      -- Apply minimum constraint
      local tab_width = math.max(min_tab_width, optimal_width)
      
      return tab_width
    end
    
    -- Pad or truncate text to exact width
    local function fit_to_width(text, width, center_align)
      local text_len = vim.fn.strdisplaywidth(text)
      if text_len < width then
        -- Pad with spaces (center if requested and not truncated)
        local total_padding = width - text_len
        if center_align then
          local left_padding = math.floor(total_padding / 2)
          local right_padding = total_padding - left_padding
          return string.rep(" ", left_padding) .. text .. string.rep(" ", right_padding)
        else
          return text .. string.rep(" ", total_padding)
        end
      elseif text_len > width then
        -- Truncate with UTF-8 support
        local result = ""
        local current_width = 0
        local chars = vim.fn.split(text, "\\zs")
        
        for _, char in ipairs(chars) do
          local char_width = vim.fn.strdisplaywidth(char)
          if current_width + char_width <= width - 2 then
            result = result .. char
            current_width = current_width + char_width
          else
            break
          end
        end
        
        -- Add ellipsis and pad to exact width
        result = result .. ".."
        local result_width = vim.fn.strdisplaywidth(result)
        if result_width < width then
          result = result .. string.rep(" ", width - result_width)
        end
        return result
      else
        return text
      end
    end
    
    -- Smart truncate filename function
    local function truncate_filename(filename, max_width)
      if #filename <= max_width then
        return filename
      end
      
      -- For very short widths, just truncate
      if max_width < 7 then
        return string.sub(filename, 1, max_width)
      end
      
      -- Try to keep extension
      local name, ext = filename:match("^(.+)(%.[^.]+)$")
      if name and ext and #ext <= 4 then
        local available = max_width - #ext - 2
        
        -- Smart truncation: show start and end
        if available > 4 then
          local start_len = math.floor(available / 2)
          local end_len = available - start_len
          return string.sub(name, 1, start_len) .. ".." .. string.sub(name, -end_len) .. ext
        elseif available > 2 then
          return string.sub(name, 1, available) .. ".." .. ext
        end
      end
      
      -- Fallback: simple truncation
      return string.sub(filename, 1, max_width - 2) .. ".."
    end
    
    -- Get file type icon (minimal nerd font icons)
    local function get_filetype_icon(filename)
      local ext = filename:match("%.([^.]+)$")
      if not ext then return "" end
      
      -- Minimal nerd font icons
      local icons = {
        lua = "",
        js = "", jsx = "", ts = "", tsx = "",
        py = "",
        go = "",
        rs = "",
        c = "", cpp = "", h = "",
        java = "",
        rb = "",
        sh = "", bash = "",
        vim = "",
        md = "",
        json = "", yaml = "", yml = "", toml = "",
        html = "", css = "", scss = "",
        git = "",
        lock = "",
        txt = "",
        conf = "", config = "",
        env = "",
        sql = "",
        docker = "",
        makefile = "",
        cmake = "",
        build = "",
      }
      
      return icons[ext:lower()] or ""
    end
    
    require("tabby.tabline").set(function(line)
      -- First pass: calculate max content width including all elements
      local max_content_width = 0
      local tabs_info = {}
      
      for i = 1, vim.fn.tabpagenr('$') do
        local tab_id = i
        local buflist = vim.fn.tabpagebuflist(tab_id)
        
        -- Skip if tabpagebuflist returns unexpected value
        if type(buflist) == "table" and #buflist > 0 then
          local winnr = vim.fn.tabpagewinnr(tab_id)
          local bufnr = buflist[winnr] or buflist[1]
          
          if bufnr then
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
            if filename == "" then filename = "[No Name]" end
          
            -- Get parent directory (full, no truncation in first pass)
            local filepath = vim.api.nvim_buf_get_name(bufnr)
            local parent_dir = ""
            if filepath ~= "" then
              local parts = vim.split(filepath, "/")
              if #parts > 1 then
                parent_dir = parts[#parts - 1]
                -- Don't truncate in first pass to get accurate width
              end
            end
            
            -- Build complete tab content
            local is_current = i == vim.fn.tabpagenr()
            local content = is_current and "▎" or " "
            content = content .. i .. " "  -- tab number
            
            local icon = get_filetype_icon(filename)
            if icon ~= "" then
              content = content .. icon .. " "
            end
            content = content .. filename
            if parent_dir ~= "" then
              content = content .. " [" .. parent_dir .. "]"
            end
            
            -- Get all status indicators
            local modified = vim.bo[bufnr].modified
            local readonly = vim.bo[bufnr].readonly
            local git_status = get_git_status(bufnr)
            local diagnostics = get_diagnostics(bufnr)
            
            -- Add status indicators
            local status = ""
            if modified then status = status .. "*" end
            if git_status and git_status.has_changes then
              if git_status.added > 0 then
                status = status .. "+"
              elseif git_status.changed > 0 then
                status = status .. "~"
              end
            end
            if readonly then status = status .. "" end
            
            if status ~= "" then
              content = content .. " " .. status
            end
            
            -- Add diagnostics
            if diagnostics.error > 0 then
              content = content .. string.format(" %d", diagnostics.error)
            end
            if diagnostics.warn > 0 then
              content = content .. string.format(" %d", diagnostics.warn)
            end
            
            -- Add final padding
            content = content .. " "
            
            local content_width = vim.fn.strdisplaywidth(content)
            max_content_width = math.max(max_content_width, content_width)
            
            -- Store info for second pass
            tabs_info[i] = {
              filename = filename,
              parent_dir = parent_dir,
              modified = modified,
              bufnr = bufnr
            }
          end
        end
      end
      
      -- Calculate optimal tab width based on max content
      local tab_width = calculate_tab_width(max_content_width)
      
      return {
        line.tabs().foreach(function(tab)
          local hl = tab.is_current() and theme.current_tab or theme.tab
          
          -- Use pre-calculated tab width
          -- tab_width is already calculated above
          
          -- Get buffer number for this tab
          local tab_id = tab.id
          local bufnr = nil
          
          -- First try standard method
          local buflist = vim.fn.tabpagebuflist(tab_id)
          if type(buflist) == "table" and #buflist > 0 then
            local winnr = vim.fn.tabpagewinnr(tab_id)
            bufnr = buflist[winnr] or buflist[1]
          end
          
          -- If that didn't work, try alternative method (for Diffview etc)
          if not bufnr then
            local wins = tab.wins()
            if wins and #wins > 0 then
              -- Try each window to find a valid buffer
              for _, win in ipairs(wins) do
                if win and win.buf then
                  local win_bufnr = win.buf().id
                  -- Check if this buffer has a name
                  local bufname = vim.api.nvim_buf_get_name(win_bufnr)
                  if bufname and bufname ~= "" then
                    bufnr = win_bufnr
                    break
                  elseif not bufnr then
                    -- Use this as fallback if no named buffer found
                    bufnr = win_bufnr
                  end
                end
              end
            end
          end
          
          -- If still no buffer, return default
          if not bufnr then
            return { 
              tab.number() .. " [No Name] ",
              hl = tab.is_current() and theme.current_tab or theme.tab,
              margin = "",
            }
          end
          
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
          
          if filename == "" then
            -- Try to get tab name from various sources
            -- 1. Try tabby's tab.name()
            local tab_name = tab.name()
            if tab_name and tab_name ~= "" then
              filename = tab_name
            else
              -- 2. Try to get from tab variable (used by some plugins like Diffview)
              local tab_var_name = vim.fn.gettabvar(tab_id, "diffview_title", "")
              if tab_var_name ~= "" then
                filename = tab_var_name
              else
                -- 3. Try generic tab name variable
                tab_var_name = vim.fn.gettabvar(tab_id, "name", "")
                if tab_var_name ~= "" then
                  filename = tab_var_name
                else
                  filename = "[No Name]"
                end
              end
            end
          end
          
          -- Get parent directory for context
          local filepath = vim.api.nvim_buf_get_name(bufnr)
          local parent_dir = ""
          local parent_dir_full = ""
          if filepath ~= "" then
            local parts = vim.split(filepath, "/")
            if #parts > 1 then
              parent_dir_full = parts[#parts - 1]
              parent_dir = parent_dir_full
            end
          end
          
          -- Get diagnostics
          local diagnostics = get_diagnostics(bufnr)
          
          -- Check modification state
          local modified = vim.bo[bufnr].modified
          local readonly = vim.bo[bufnr].readonly
          
          -- Get git status
          local git_status = get_git_status(bufnr)
          
          -- Tab number
          local tab_number = tab.number()
          
          -- Build tab label with improved formatting
          local is_current = tab.is_current()
          
          -- Use regular numbers for better readability
          local label = ""
          if is_current then
            label = "▎" .. tab_number .. " "
          else
            label = " " .. tab_number .. " "
          end
          
          -- Add filename with file type icon
          local filetype_icon = get_filetype_icon(filename)
          if filetype_icon ~= "" and tab_width > 20 then
            label = label .. filetype_icon .. " "
          end
          
          -- Add filename
          label = label .. filename
          
          -- Calculate status indicators first
          local status_suffix = ""
          
          -- Modified indicator
          if modified then
            status_suffix = status_suffix .. "*"
          end
          
          -- Git indicator
          if git_status and git_status.has_changes then
            if git_status.added > 0 then
              status_suffix = status_suffix .. "+"
            elseif git_status.changed > 0 then
              status_suffix = status_suffix .. "~"
            end
          end
          
          -- Readonly indicator (using lock icon)
          if readonly then
            status_suffix = status_suffix .. ""
          end
          
          -- Calculate diagnostics space
          local diagnostics_suffix = ""
          if tab_width > 30 and diagnostics.error > 0 then
            diagnostics_suffix = string.format(" %d", diagnostics.error)
          end
          if tab_width > 40 and diagnostics.warn > 0 then
            diagnostics_suffix = diagnostics_suffix .. string.format(" %d", diagnostics.warn)
          end
          
          -- Track if any truncation occurred
          local content_truncated = false
          
          -- Add parent directory with dynamic truncation
          if parent_dir ~= "" then
            -- Calculate available space for parent directory
            local current_label_width = vim.fn.strdisplaywidth(label)
            local status_width = vim.fn.strdisplaywidth(status_suffix)
            if status_suffix ~= "" then
              status_width = status_width + 1 -- Account for space before status
            end
            local diagnostics_width = vim.fn.strdisplaywidth(diagnostics_suffix)
            local brackets_width = 3 -- " [" + "]"
            local padding = 1 -- Final padding (reduced from 2)
            local available_for_parent = tab_width - current_label_width - status_width - diagnostics_width - brackets_width - padding
            
            if available_for_parent > 3 then
              -- Truncate parent directory if needed
              if vim.fn.strdisplaywidth(parent_dir) > available_for_parent then
                -- Use UTF-8 aware truncation
                local truncated = ""
                local width = 0
                local target = available_for_parent - 2 -- Reserve 2 for ".."
                for char in parent_dir:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
                  local char_width = vim.fn.strdisplaywidth(char)
                  if width + char_width <= target then
                    truncated = truncated .. char
                    width = width + char_width
                  else
                    break
                  end
                end
                parent_dir = truncated .. ".."
                content_truncated = true
              end
              label = label .. " [" .. parent_dir .. "]"
            else
              -- Parent directory doesn't fit at all
              content_truncated = true
            end
          end
          
          if status_suffix ~= "" then
            label = label .. " " .. status_suffix
          end
          
          -- Highlight is now based only on selection state
          -- Status is shown through indicators, not styling
          
          -- Add diagnostics (already calculated above)
          label = label .. diagnostics_suffix
          
          -- Check if content was truncated (either parent dir or overall)
          local label_width = vim.fn.strdisplaywidth(label)
          local was_truncated = content_truncated or (label_width > tab_width)
          
          -- Fit label to exact tab width (center align if not truncated)
          local final_label = fit_to_width(label, tab_width, not was_truncated)
          
          return {
            final_label,
            hl = hl,
            margin = "",
          }
        end),
        line.spacer(),
        hl = theme.fill,
      }
    end)
    
    -- Define custom highlight groups
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        -- Get base highlights
        local tabline_base = vim.api.nvim_get_hl(0, { name = "TabLine" })
        local tablinesel_base = vim.api.nvim_get_hl(0, { name = "TabLineSel" })
        local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
        local visual = vim.api.nvim_get_hl(0, { name = "Visual" })
        local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine" })
        local comment = vim.api.nvim_get_hl(0, { name = "Comment" })
        
        -- Get theme-specific colors for more subtle text
        local statement = vim.api.nvim_get_hl(0, { name = "Statement" })
        local function_hl = vim.api.nvim_get_hl(0, { name = "Function" })
        local type_hl = vim.api.nvim_get_hl(0, { name = "Type" })
        local identifier = vim.api.nvim_get_hl(0, { name = "Identifier" })
        local title = vim.api.nvim_get_hl(0, { name = "Title" })
        
        -- Use a more subtle background for selected tab
        -- Try Visual first, then CursorLine, then a slightly lighter version of TabLine
        local selected_bg = visual.bg or cursorline.bg
        if not selected_bg and tabline_base.bg then
          -- Create a slightly lighter/darker version of TabLine background
          selected_bg = tabline_base.bg
        end
        
        -- Use a soft, eye-friendly white color
        -- This is a warm white that's easier on the eyes than pure white
        local soft_white = "#F5F2E8"  -- Cream-white color
        
        -- Alternative soft whites (can be switched based on preference):
        -- local soft_white = "#FAF6F0"  -- Very light beige-white
        -- local soft_white = "#F0EFEB"  -- Light gray-white
        -- local soft_white = "#E8E6E1"  -- Slightly darker soft white
        
        -- Update TabLineSel with soft white and subtle styling
        vim.api.nvim_set_hl(0, "TabLineSel", {
          bg = selected_bg,
          fg = soft_white,
          bold = true,  -- Use bold for emphasis
        })
        
        -- Make inactive tabs use comment color for better contrast
        vim.api.nvim_set_hl(0, "TabLine", {
          bg = tabline_base.bg,
          fg = comment.fg or tabline_base.fg,
        })
      end,
    })
    
    -- Initial execution
    vim.cmd("doautocmd ColorScheme")
    
    -- Hide when only one tab
    vim.o.showtabline = 1
  end,
}