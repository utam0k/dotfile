-- Tabby.nvim: Highly customizable tabline (simplified without icons)
return {
  "nanozuki/tabby.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  event = "VimEnter",
  config = function()
    local presets = require("tabby.presets")
    local preset = vim.deepcopy(presets.active_wins_at_tail)
    local tab_name = require("tabby.feature.tab_name")
    local win_name = require("tabby.feature.win_name")

    -- Simple tab labels without icons
    preset.active_tab.label = function(tabid)
      return {
        string.format(" %d: %s ",
                      vim.api.nvim_tabpage_get_number(tabid),
                      tab_name.get(tabid)),
        hl = "TabLineSel",
      }
    end

    preset.inactive_tab.label = function(tabid)
      return {
        string.format(" %d: %s ",
                      vim.api.nvim_tabpage_get_number(tabid),
                      tab_name.get(tabid)),
        hl = "TabLine",
      }
    end

    -- Simple window labels without icons
    preset.top_win.label = function(winid)
      return {
        string.format(" %s ", win_name.get(winid, { mode = 'unique' })),
        hl = "TabLine",
      }
    end

    preset.win.label = function(winid)
      return {
        string.format(" %s ", win_name.get(winid, { mode = 'unique' })),
        hl = "TabLine",
      }
    end

    -- Remove decorative head and tail
    preset.head = nil
    preset.tail = nil

    require("tabby").setup({ tabline = preset })

    -- Show tabline only when there are at least 2 tabs
    vim.o.showtabline = 1
  end,
}