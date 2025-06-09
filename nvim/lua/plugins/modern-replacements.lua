-- Modern Lua replacements for older Vimscript plugins
return {
  -- Replace lightline.vim with lualine.nvim
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      local lualine = require("lualine")
      
      -- Custom components
      local custom_filename = function()
        local filetype = vim.bo.filetype
        if filetype == "neo-tree" then
          return "Neo-tree"
        elseif filetype == "oil" then
          return "Oil"
        else
          local filename = vim.fn.expand("%:.")
          if filename == "" then
            filename = "[No Name]"
          end
          
          local modified = vim.bo.modified and " +" or ""
          local readonly = vim.bo.readonly and " !" or ""
          
          return readonly .. filename .. modified
        end
      end
      
      local custom_branch = function()
        local filetype = vim.bo.filetype
        if filetype == "help" or filetype == "neo-tree" or filetype == "oil" then
          return ""
        end
        
        local branch = vim.fn["fugitive#head"]()
        return branch ~= "" and " " .. branch or ""
      end
      
      lualine.setup({
        options = {
          theme = "auto", -- Automatically detect from colorscheme
          icons_enabled = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          always_divide_middle = true,
          globalstatus = false,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { custom_branch, "diff", "diagnostics" },
          lualine_c = { custom_filename },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { custom_filename },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        extensions = { "neo-tree", "fugitive" },
      })
    end,
  },
  
  -- Replace tcomment_vim with Comment.nvim
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    config = function()
      require("Comment").setup({
        -- Use the same keymaps as tcomment_vim
        mappings = {
          basic = true,
          extra = false,
        },
        toggler = {
          line = "gcc",
          block = "gbc",
        },
        opleader = {
          line = "gc",
          block = "gb",
        },
      })
    end,
  },
  
  -- Replace vim-bookmarks with marks.nvim
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    config = function()
      require("marks").setup({
        default_mappings = false,
        builtin_marks = { ".", "<", ">", "^" },
        cyclic = true,
        force_write_shada = false,
        refresh_interval = 250,
        sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
        excluded_filetypes = { "neo-tree", "oil" },
        bookmark_0 = {
          sign = "",
          virt_text = "bookmark",
          annotate = false,
        },
        mappings = {
          toggle = "mm",          -- Toggle mark at cursor
          next = "mn",            -- Go to next mark
          prev = "mp",            -- Go to previous mark
          preview = "m:",         -- Preview mark
          set_next = "m,",        -- Set next available lowercase mark
          delete_line = "dm",     -- Delete all marks on line
          delete_buf = "dm-",     -- Delete all marks in buffer
          next_bookmark = "m]",   -- Go to next bookmark
          prev_bookmark = "m[",   -- Go to previous bookmark
          annotate = "mi",        -- Annotate mark
        },
      })
      
      -- Additional keymaps for compatibility with vim-bookmarks
      vim.keymap.set("n", "<leader>ma", "<cmd>MarksListAll<cr>", { desc = "List all marks" })
      vim.keymap.set("n", "<leader>mb", "<cmd>MarksListBuf<cr>", { desc = "List buffer marks" })
    end,
  },
  
  -- Replace tagbar with aerial.nvim (modern outline viewer)
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "AerialToggle", "AerialOpen", "AerialInfo" },
    keys = {
      { "<F8>", "<cmd>AerialToggle<cr>", desc = "Toggle Aerial" },
      { "{", "<cmd>AerialPrev<cr>", desc = "Previous symbol" },
      { "}", "<cmd>AerialNext<cr>", desc = "Next symbol" },
    },
    config = function()
      require("aerial").setup({
        backends = { "treesitter", "lsp", "markdown", "man" },
        layout = {
          max_width = { 40, 0.2 },
          width = nil,
          min_width = 20,
          default_direction = "right",
          placement = "window",
        },
        attach_mode = "window",
        close_automatic_events = { "unsupported" },
        keymaps = {
          ["?"] = "actions.show_help",
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.jump",
          ["<2-LeftMouse>"] = "actions.jump",
          ["<C-v>"] = "actions.jump_vsplit",
          ["<C-s>"] = "actions.jump_split",
          ["p"] = "actions.scroll",
          ["<C-j>"] = "actions.down_and_scroll",
          ["<C-k>"] = "actions.up_and_scroll",
          ["{"] = "actions.prev",
          ["}"] = "actions.next",
          ["[["] = "actions.prev_up",
          ["]]"] = "actions.next_up",
          ["q"] = "actions.close",
          ["o"] = "actions.tree_toggle",
          ["za"] = "actions.tree_toggle",
          ["O"] = "actions.tree_toggle_recursive",
          ["zA"] = "actions.tree_toggle_recursive",
          ["l"] = "actions.tree_open",
          ["zo"] = "actions.tree_open",
          ["L"] = "actions.tree_open_recursive",
          ["zO"] = "actions.tree_open_recursive",
          ["h"] = "actions.tree_close",
          ["zc"] = "actions.tree_close",
          ["H"] = "actions.tree_close_recursive",
          ["zC"] = "actions.tree_close_recursive",
          ["zr"] = "actions.tree_increase_fold_level",
          ["zR"] = "actions.tree_open_all",
          ["zm"] = "actions.tree_decrease_fold_level",
          ["zM"] = "actions.tree_close_all",
          ["zx"] = "actions.tree_sync_folds",
          ["zX"] = "actions.tree_sync_folds",
        },
        filter_kind = false,
        highlight_mode = "split_width",
        highlight_on_hover = true,
        icons = {
          File = " ",
          Module = " ",
          Namespace = " ",
          Package = " ",
          Class = " ",
          Method = " ",
          Property = " ",
          Field = " ",
          Constructor = " ",
          Enum = " ",
          Interface = " ",
          Function = " ",
          Variable = " ",
          Constant = " ",
          String = " ",
          Number = " ",
          Boolean = " ",
          Array = " ",
          Object = " ",
          Key = " ",
          Null = " ",
          EnumMember = " ",
          Struct = " ",
          Event = " ",
          Operator = " ",
          TypeParameter = " ",
        },
        show_guides = true,
        guides = {
          mid_item = "├─",
          last_item = "└─",
          nested_top = "│ ",
          whitespace = "  ",
        },
      })
      
      -- Integration with telescope
      vim.keymap.set("n", "<leader>fa", "<cmd>Telescope aerial<cr>", { desc = "Search symbols (Aerial)" })
    end,
  },
  
  -- Note: ctrlsf.vim functionality is already covered by Telescope live_grep
  -- and the existing Telescope configuration with smart_open
}
