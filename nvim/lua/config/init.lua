-- Configuration loader

-- Load core settings
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Bootstrap and load lazy.nvim
require("config.lazy")
