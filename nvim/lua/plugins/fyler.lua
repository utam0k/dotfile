-- Experimental Fyler setup so Neo-tree can focus on Git/Buffers
return {
  {
    "A7Lavinraj/fyler.nvim",
    branch = "stable",
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
          require("fyler").toggle({ kind = "float" })
        end,
        desc = "Fyler: Toggle explorer",
      },
    },
    cmd = { "Fyler" },
    opts = {
      view = { bufname = "Fyler" },
      git_status = {
        enabled = true,
      },
      close_on_select = true,
      confirm_simple = false,
      default_explorer = false,
      icon_provider = "mini_icons",
      win = {
        win_opts = {
          number = false,
          relativenumber = false,
        },
      },
    },
    config = function(_, opts)
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
    end,
  },
}
