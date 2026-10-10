-- Configuration loader

-- Load core settings
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.autoreload").setup()

-- Bootstrap and load lazy.nvim
require("config.lazy")
