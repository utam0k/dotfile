-- File tree explorer (Zed-like sidebar)
local function calc_width()
  local width = math.floor(vim.o.columns * 0.2)
  if width < 24 then
    width = 24
  elseif width > 38 then
    width = 38
  end
  return width
end

local function balance_non_tree_windows()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local groups = {}

  for _, win in ipairs(wins) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative == "" then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local pos = vim.api.nvim_win_get_position(win)
      local row = pos[1]
      local key = tostring(row)
      local group = groups[key] or { wins = {}, total_width = 0, tree_width = 0 }
      local width = vim.api.nvim_win_get_width(win)

      group.total_width = group.total_width + width
      if ft == "NvimTree" then
        group.tree_width = group.tree_width + width
      else
        table.insert(group.wins, win)
      end

      groups[key] = group
    end
  end

  for _, group in pairs(groups) do
    local count = #group.wins
    if count > 1 then
      local available = group.total_width - group.tree_width
      if available > 0 then
        local target = math.floor(available / count)
        for _, win in ipairs(group.wins) do
          pcall(vim.api.nvim_win_set_width, win, target)
        end
      end
    end
  end
end
local function set_git_filter_state(explorer, git_only)
  explorer.filters.enabled = true
  explorer.filters.state.git_clean = git_only
  explorer.filters.state.git_ignored = git_only
end

local function toggle_view(git_only)
  local api = require("nvim-tree.api")
  local core = require("nvim-tree.core")

  if api.tree.is_visible() then
    local explorer = core.get_explorer()
    if not explorer then
      return
    end

    local is_git_only = explorer.filters.state.git_clean and explorer.filters.state.git_ignored
    if is_git_only == git_only then
      api.tree.close()
      return
    end
  else
    api.tree.open()
  end

  local explorer = core.get_explorer()
  if not explorer then
    return
  end

  set_git_filter_state(explorer, git_only)
  explorer:reload_explorer()
  api.tree.resize({ absolute = calc_width() })
  balance_non_tree_windows()
  if git_only then
    api.tree.expand_all()
  end
  api.tree.focus()
end

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  keys = {
    { "<Space>e", function() toggle_view(false) end, desc = "NvimTree: Toggle normal view" },
    { "<Space>g", function() toggle_view(true) end, desc = "NvimTree: Toggle git-only view" },
  },
  config = function()
    local function resize_tree()
      local width = calc_width()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "NvimTree" then
          pcall(vim.api.nvim_win_set_width, win, width)
        end
      end
    end

    require("nvim-tree").setup({
      disable_netrw = true,
      hijack_netrw = true,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      view = {
        side = "left",
        width = calc_width(),
        preserve_window_proportions = true,
        signcolumn = "no",
      },
      renderer = {
        root_folder_label = false,
        group_empty = true,
        highlight_git = "name",
        highlight_opened_files = "name",
        indent_markers = {
          enable = true,
          icons = {
            corner = " ",
            edge = "▏",
            item = "▏",
            none = " ",
          },
        },
        icons = {
          webdev_colors = false,
          show = {
            file = false,
            folder = false,
            folder_arrow = true,
            git = true,
          },
          glyphs = {
            folder = {
              arrow_closed = ">",
              arrow_open = "v",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unstaged = "~",
              staged = "+",
              unmerged = "!",
              renamed = ">",
              untracked = "?",
              deleted = "x",
              ignored = ".",
            },
          },
        },
      },
      git = {
        enable = true,
        ignore = false,
        show_on_dirs = true,
        show_on_open_dirs = true,
      },
      filters = {
        dotfiles = false,
        git_ignored = false,
        git_clean = false,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = true,
        },
      },
    })

    local augroup = vim.api.nvim_create_augroup("NvimTreeResize", { clear = true })
    vim.api.nvim_create_autocmd({ "VimResized", "FileType" }, {
      group = augroup,
      pattern = "NvimTree",
      callback = resize_tree,
      desc = "Resize NvimTree sidebar",
    })

    local events = require("nvim-tree.events")
    events.subscribe(events.Event.TreeClose, function()
      vim.schedule(balance_non_tree_windows)
    end)
  end,
}
