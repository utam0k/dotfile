local M = {}

local function to_exe(path)
  if vim.loop.os_uname().sysname == "Windows_NT" then
    return path .. ".exe"
  end
  return path
end

---Resolve codelldb adapter and liblldb paths installed via Mason.
-- @return table|nil paths { codelldb, liblldb }
function M.get_paths()
  local data_path = vim.fn.stdpath("data")
  local package_path = data_path .. "/mason/packages/codelldb"

  -- Adapter executable
  local extension_path = package_path .. "/extension/"
  local codelldb_path = to_exe(extension_path .. "adapter/codelldb")
  if not vim.loop.fs_stat(codelldb_path) then
    codelldb_path = to_exe(package_path .. "/codelldb")
    if not vim.loop.fs_stat(codelldb_path) then
      return nil
    end
  end

  -- liblldb shared library
  local sysname = vim.loop.os_uname().sysname
  local lib_name
  if sysname == "Darwin" then
    lib_name = "liblldb.dylib"
  elseif sysname == "Windows_NT" then
    lib_name = "liblldb.dll"
  else
    lib_name = "liblldb.so"
  end

  local lib_paths = {
    extension_path .. "lldb/lib/" .. lib_name,
    package_path .. "/liblldb/" .. lib_name,
    package_path .. "/lldb/lib/" .. lib_name,
  }

  local liblldb_path
  for _, candidate in ipairs(lib_paths) do
    if vim.loop.fs_stat(candidate) then
      liblldb_path = candidate
      break
    end
  end

  if not liblldb_path then
    return nil
  end

  return {
    codelldb = codelldb_path,
    liblldb = liblldb_path,
  }
end

return M
