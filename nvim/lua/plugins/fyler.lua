-- Experimental Fyler setup so Neo-tree can focus on Git/Buffers
return {
  {
    "A7Lavinraj/fyler.nvim",
    branch = "stable",
    enabled = false,
    -- Requires Neovim 0.11+. Skip loading (and the keymaps) on older versions to
    -- avoid calling missing API functions like `fyler.toggle`.
    cond = vim.fn.has("nvim-0.11") == 1,
    -- Eager-load after startup so API is ready before keymaps are pressed
    event = "VeryLazy",
    dependencies = {
      {
        "nvim-mini/mini.icons",
        config = function()
          require("mini.icons").setup()
        end,
      },
    },
    keys = {
      {
        "<Space>e",
        function()
          local resolve_path = vim.g._fyler_resolve_path
          local current_path = vim.api.nvim_buf_get_name(0)
          if resolve_path then
            current_path = resolve_path(current_path)
          end

          local root_dir = vim.fn.getcwd()
          if vim.g._fyler_root_dir_for_path then
            root_dir = vim.g._fyler_root_dir_for_path(current_path) or root_dir
          end
          if resolve_path then
            root_dir = resolve_path(root_dir)
          end

          require("fyler").toggle({ kind = "split_left_most", dir = root_dir })
          vim.schedule(function()
            if vim.g._fyler_expand_open_buffers then
              vim.g._fyler_expand_open_buffers(current_path, root_dir)
            elseif current_path ~= "" then
              require("fyler.views.finder").navigate(current_path)
            end
            if vim.g._fyler_resize then
              vim.g._fyler_resize()
            end
          end)
        end,
        desc = "Fyler: Toggle explorer",
      },
    },
    cmd = { "Fyler" },
    opts = {
      integrations = {
        icon = "mini_icons",
      },
      views = {
        finder = {
          close_on_select = true,
          confirm_simple = false,
          default_explorer = false,
          git_status = {
            enabled = true,
            symbols = {
              Untracked = "?",
              Added = "+",
              Modified = "●",
              Deleted = "×",
              Renamed = "»",
              Copied = "≈",
              Conflict = "!",
              Ignored = "◌",
            },
          },
          icon = {
            directory_collapsed = "▸",
            directory_expanded = "▾",
            directory_empty = "▸",
          },
          indentscope = {
            enabled = true,
            group = "FylerIndentMarker",
            marker = "▏",
          },
          win = {
            border = "none",
            kind = "split_left_most",
            kinds = {
              split_left_most = {
                width = 30,
                win_opts = {
                  winfixwidth = true,
                },
              },
            },
            win_opts = {
              number = false,
              relativenumber = false,
              cursorline = true,
              signcolumn = "no",
              wrap = false,
              winhighlight = "Normal:FylerNormal,NormalNC:FylerNormalNC,CursorLine:FylerCursorLine,EndOfBuffer:FylerNormal,NonText:FylerNormal",
            },
          },
        },
      },
    },
    config = function(_, opts)
      local function resolve_path(path)
        if not path or path == "" then
          return ""
        end
        return vim.fs.normalize(vim.fn.resolve(path))
      end

      vim.g._fyler_resolve_path = resolve_path

      local function is_under_root(path, root_dir)
        if not path or path == "" or not root_dir or root_dir == "" then
          return false
        end
        local root = root_dir
        if not vim.endswith(root, "/") then
          root = root .. "/"
        end
        return vim.startswith(path, root)
      end

      local function find_git_root(path)
        if not path or path == "" then
          return nil
        end
        local dir = vim.fs.dirname(path)
        if not dir or dir == "" then
          return nil
        end
        local result = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
        if vim.v.shell_error ~= 0 or not result or result[1] == "" then
          return nil
        end
        return resolve_path(result[1])
      end

      local function root_dir_for_path(path)
        local git_root = find_git_root(path)
        if git_root then
          return git_root
        end
        return vim.fn.getcwd()
      end

      vim.g._fyler_root_dir_for_path = root_dir_for_path

      local function is_real_file(path)
        path = resolve_path(path)
        if path == "" or path:match("^fyler://") then
          return false
        end
        return vim.fn.filereadable(path) == 1
      end

      local function unique_paths(paths)
        local seen, out = {}, {}
        for _, path in ipairs(paths) do
          if not seen[path] then
            seen[path] = true
            out[#out + 1] = path
          end
        end
        return out
      end

      local function calc_fyler_width()
        local columns = vim.o.columns
        local width = math.floor(columns * 0.2)
        if width < 24 then
          width = 24
        elseif width > 38 then
          width = 38
        end
        return width
      end

      local function resize_fyler_windows()
        local width = calc_fyler_width()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "fyler" then
            pcall(vim.api.nvim_win_set_width, win, width)
          end
        end
      end

      -- Share resize helper for the toggle mapping.
      vim.g._fyler_resize = resize_fyler_windows

      local function expand_open_buffers(active_path)
        active_path = resolve_path(active_path)
        local root_dir = ""
        if vim.g._fyler_root_dir_for_path then
          root_dir = vim.g._fyler_root_dir_for_path(active_path) or ""
        end
        root_dir = resolve_path(root_dir)

        local paths = {}
        for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
          if info.name ~= "" then
            local name = resolve_path(info.name)
            if is_real_file(name) and (root_dir == "" or is_under_root(name, root_dir)) then
              paths[#paths + 1] = name
            end
          end
        end

        paths = unique_paths(paths)

        if active_path and active_path ~= "" then
          local filtered = {}
          for _, path in ipairs(paths) do
            if path ~= active_path then
              filtered[#filtered + 1] = path
            end
          end
          paths = filtered
          if is_real_file(active_path) then
            paths[#paths + 1] = active_path
          end
        end

        local function parse_git_status_z(output)
          local results = {}
          if not output or output == "" then
            return results
          end

          local tokens = vim.split(output, "\0", { plain = true })
          local i = 1
          while i <= #tokens do
            local token = tokens[i]
            if token and token ~= "" then
              local status, path = token:match("^(.)(.)%s+(.+)$")
              if status and path then
                if status == "R" or status == "C" then
                  local next_path = tokens[i + 1]
                  if next_path and next_path ~= "" then
                    results[#results + 1] = next_path
                    i = i + 1
                  end
                else
                  results[#results + 1] = path
                end
              end
            end
            i = i + 1
          end
          return results
        end

        local function gather_git_changed_paths(cb)
          if not root_dir or root_dir == "" then
            return cb({})
          end
          vim.system(
            { "git", "-C", root_dir, "status", "--porcelain", "-z", "--untracked-files=normal" },
            { text = true, stdout = true, stderr = false },
            function(result)
              if not result or result.code ~= 0 then
                return cb({})
              end
              local rels = parse_git_status_z(result.stdout or "")
              if #rels == 0 then
                return cb({})
              end
              local expanded = {}
              for _, rel in ipairs(rels) do
                local full = resolve_path(root_dir .. "/" .. rel)
                if is_real_file(full) and is_under_root(full, root_dir) then
                  expanded[#expanded + 1] = full
                end
              end
              cb(expanded)
            end
          )
        end

        local function navigate_paths(final_paths)
          for _, path in ipairs(final_paths) do
            require("fyler.views.finder").navigate(path)
          end
        end

        local function run_with_paths(final_paths)
          local finder = require("fyler.views.finder")
          if finder and finder._current and finder._current.dispatch_refresh then
            finder._current:dispatch_refresh(function()
              navigate_paths(final_paths)
            end)
          else
            navigate_paths(final_paths)
          end
        end

        gather_git_changed_paths(function(git_paths)
          local combined = {}
          for _, path in ipairs(paths) do
            combined[#combined + 1] = path
          end
          for _, path in ipairs(git_paths) do
            combined[#combined + 1] = path
          end
          combined = unique_paths(combined)
          run_with_paths(combined)
        end)
      end

      -- Share expand helper for the toggle mapping.
      vim.g._fyler_expand_open_buffers = expand_open_buffers

      opts.views.finder.win.kinds.split_left_most.width = calc_fyler_width()

      local fs = require("fyler.lib.fs")
      local original_ls = fs.ls
      local show_hidden = false
      local git_root_cache = {}

      local function get_git_root_async(dir, cb)
        dir = vim.fs.normalize(dir)
        if git_root_cache[dir] ~= nil then
          vim.schedule(function()
            cb(git_root_cache[dir] or nil)
          end)
          return
        end

        vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true, stdout = true, stderr = false }, function(result)
          local root = nil
          if result and result.code == 0 then
            root = vim.trim(result.stdout)
          end
          git_root_cache[dir] = root or false
          cb(root)
        end)
      end

      local function filter_gitignored_async(dir, items, cb)
        get_git_root_async(dir, function(root)
          if not root then
            cb(items)
            return
          end

          local paths = {}
          for _, item in ipairs(items) do
            paths[#paths + 1] = item.path
          end
          if #paths == 0 then
            cb(items)
            return
          end

          local input = table.concat(paths, "\n") .. "\n"
          vim.system({ "git", "-C", dir, "check-ignore", "--stdin" }, { stdin = input, text = true, stdout = true, stderr = false }, function(result)
            if not result or not (result.code == 0 or result.code == 1) then
              cb(items)
              return
            end

            local ignored = {}
            for line in string.gmatch(result.stdout or "", "[^\n]+") do
              ignored[vim.trim(line)] = true
            end

            if vim.tbl_isempty(ignored) then
              cb(items)
              return
            end

            cb(vim.tbl_filter(function(item)
              return not ignored[item.path]
            end, items))
          end)
        end)
      end

      fs.ls = function(path, callback)
        original_ls(path, function(err, items)
          if err or not items then
            callback(err, items)
            return
          end

          local filtered = items
          if not show_hidden then
            filtered = vim.tbl_filter(function(item)
              local name = item.name or vim.fs.basename(item.path)
              return not name:match("^%.")
            end, filtered)

            filter_gitignored_async(path, filtered, function(result_items)
              callback(nil, result_items)
            end)
            return
          end

          callback(nil, filtered)
        end)
      end

      opts.mappings = opts.mappings or {}
      opts.mappings.zh = function(explorer)
        show_hidden = not show_hidden
        vim.notify("Fyler: hidden files " .. (show_hidden and "ON" or "OFF"))
        explorer:dispatch_refresh()
      end

      require("fyler").setup(opts)

      vim.api.nvim_create_user_command("FylerToggleHidden", function()
        show_hidden = not show_hidden
        local current = require("fyler").current and require("fyler").current()
        if current then
          current:dispatch_refresh()
        end
        vim.notify("Fyler: hidden files " .. (show_hidden and "ON" or "OFF"))
      end, {})

      local augroup = vim.api.nvim_create_augroup("FylerResize", { clear = true })
      vim.api.nvim_create_autocmd("VimResized", {
        group = augroup,
        callback = resize_fyler_windows,
        desc = "Resize Fyler sidebar on VimResized",
      })
      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = "fyler",
        callback = resize_fyler_windows,
        desc = "Resize Fyler sidebar on open",
      })
    end,
  },
}
