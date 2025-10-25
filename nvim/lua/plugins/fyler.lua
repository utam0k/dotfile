-- Experimental Fyler setup so Neo-tree can focus on Git/Buffers
return {
  {
    "A7Lavinraj/fyler.nvim",
    branch = "stable",
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
      local original_listdir = fs.listdir
      local show_hidden = false
      local git_root_cache = {}

      local function get_git_root(dir)
        dir = vim.fs.normalize(dir)
        if git_root_cache[dir] ~= nil then
          return git_root_cache[dir] or nil
        end
        local result = vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true, stdout = true, stderr = false }):wait()
        if result.code == 0 then
          local root = vim.trim(result.stdout)
          git_root_cache[dir] = root
          return root
        end
        git_root_cache[dir] = false
        return nil
      end

      local function filter_gitignored(dir, items)
        local root = get_git_root(dir)
        if not root then
          return items
        end

        local paths = {}
        for _, item in ipairs(items) do
          paths[#paths + 1] = item.path
        end
        if #paths == 0 then
          return items
        end

        local input = table.concat(paths, "\n") .. "\n"
        local result = vim.system({ "git", "-C", dir, "check-ignore", "--stdin" }, { stdin = input, text = true, stdout = true, stderr = false }):wait()
        if not (result.code == 0 or result.code == 1) then
          return items
        end

        local ignored = {}
        for line in string.gmatch(result.stdout or "", "[^\n]+") do
          ignored[vim.trim(line)] = true
        end

        if vim.tbl_isempty(ignored) then
          return items
        end

        return vim.tbl_filter(function(item)
          return not ignored[item.path]
        end, items)
      end

      fs.listdir = function(path)
        local items = original_listdir(path)
        if show_hidden then
          return items
        end
        local without_dotfiles = vim.tbl_filter(function(item)
          local name = item.name or vim.fs.basename(item.path)
          return not name:match("^%.")
        end, items)
        return filter_gitignored(path, without_dotfiles)
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
