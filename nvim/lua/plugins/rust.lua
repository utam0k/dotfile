-- Enhanced Rust tooling via rustaceanvim
return {
  "mrcjkb/rustaceanvim",
  version = "^4",
  ft = { "rust" },
  dependencies = {
    "mfussenegger/nvim-dap",
    "williamboman/mason.nvim",
  },
  init = function()
    local helpers = require("config.lsp_helpers")

    local function get_codelldb_adapter()
      local ok, mason_registry = pcall(require, "mason-registry")
      if ok and mason_registry.has_package and mason_registry.has_package("codelldb") then
        local ok_pkg, codelldb_pkg = pcall(mason_registry.get_package, "codelldb")
        if ok_pkg and codelldb_pkg then
          local installed = true
          if type(codelldb_pkg.is_installed) == "function" then
            installed = codelldb_pkg:is_installed()
          elseif type(codelldb_pkg.installed) == "boolean" then
            installed = codelldb_pkg.installed
          end
          if not installed then
            vim.notify("codelldb is not installed yet. Run :Mason and install codelldb.", vim.log.levels.WARN)
            return nil
          end
        else
          vim.notify("Failed to load codelldb package from Mason: " .. tostring(codelldb_pkg), vim.log.levels.ERROR)
        end
      end

      local data_path = vim.fn.stdpath("data")
      local package_path = data_path .. "/mason/packages/codelldb"
      local extension_path = package_path .. "/extension/"
      local codelldb_path = extension_path .. "adapter/codelldb"

      if vim.loop.os_uname().sysname == "Windows_NT" then
        codelldb_path = codelldb_path .. ".exe"
      end

      if not vim.loop.fs_stat(codelldb_path) then
        -- fallback to plain binary if adapter not found
        codelldb_path = package_path .. "/codelldb"
        if vim.loop.os_uname().sysname == "Windows_NT" then
          codelldb_path = codelldb_path .. ".exe"
        end
        if not vim.loop.fs_stat(codelldb_path) then
          vim.notify("Failed to resolve codelldb install path.", vim.log.levels.ERROR)
          return nil
        end
        extension_path = package_path .. "/extension/"
      end

      local sysname = vim.loop.os_uname().sysname
      local lib_name
      if sysname == "Darwin" then
        lib_name = "liblldb.dylib"
      elseif sysname == "Windows_NT" then
        lib_name = "liblldb.dll"
      else
        lib_name = "liblldb.so"
      end

      local liblldb_path = extension_path .. "lldb/lib/" .. lib_name
      if not vim.loop.fs_stat(liblldb_path) then
        -- fallback: older packages keep liblldb next to adapter
        liblldb_path = package_path .. "/liblldb/" .. lib_name
      end

      if not vim.loop.fs_stat(liblldb_path) then
        vim.notify("Failed to locate liblldb for codelldb.", vim.log.levels.ERROR)
        return nil
      end

      local cfg = require("rustaceanvim.config")
      return cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
    end

    vim.g.rustaceanvim = {
      tools = {
        hover_actions = {
          auto_focus = true,
        },
        executor = require("rustaceanvim.executors").termopen,
      },
      server = {
        on_attach = helpers.on_attach,
        capabilities = helpers.make_capabilities(),
        default_settings = {
          ["rust-analyzer"] = {
            allFeatures = true,
            cargo = {
              allFeatures = true,
              features = "all",
              loadOutDirsFromCheck = true,
              buildScripts = { enable = true },
            },
            check = {
              command = "clippy",
              overrideCommand = {
                "cargo",
                "clippy",
                "--message-format=json",
                "--all-targets",
                "--all-features",
                "--",
                "-Dwarnings",
              },
            },
            procMacro = {
              enable = true,
            },
            diagnostics = {
              experimental = {
                enable = true,
              },
            },
          },
        },
      },
      dap = {
        adapter = get_codelldb_adapter,
      },
    }
  end,
}
