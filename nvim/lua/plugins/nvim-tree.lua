-- File tree explorer (Zed-like sidebar)
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
    local function calc_width()
      local width = math.floor(vim.o.columns * 0.2)
      if width < 24 then
        width = 24
      elseif width > 38 then
        width = 38
      end
      return width
    end

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
  end,
}
