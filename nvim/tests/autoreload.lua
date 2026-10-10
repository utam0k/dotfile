-- Run with: NVIM_LOG_FILE=/dev/null nvim --headless -u NONE -i NONE -n -l tests/autoreload.lua
local root = vim.fn.getcwd()
local base = root .. "/.agent/autoreload-check"
vim.fn.mkdir(base, "p")
vim.env.XDG_STATE_HOME = base .. "/state"
local output = {}
local child = vim.fn.jobstart({ vim.v.progpath, "--headless", "--embed", "-u", "NONE", "-i", "NONE", "-n" }, {
	rpc = true,
	on_stderr = function(_, data)
		vim.list_extend(output, data)
	end,
})
assert(child > 0)
local function lua(code, ...)
	return vim.rpcrequest(child, "nvim_exec_lua", code, { ... })
end
local count = 0
local function wait_for(code, message)
	assert(
		vim.wait(2500, function()
			return lua(code)
		end, 20),
		message .. "\n" .. table.concat(output, "\n")
	)
end
local function pass(name)
	count = count + 1
	print("PASS " .. name)
end
local function write(path, lines)
	assert(vim.fn.writefile(lines, path) == 0)
end
local function open(path)
	lua("vim.cmd.edit(vim.fn.fnameescape(...))", path)
end
local ok, err = xpcall(function()
	lua(
		[[
local root = ...
vim.opt.runtimepath:prepend(root)
vim.o.swapfile = false
vim.o.undofile = false
vim.o.more = false
assert(vim.o.autoread)
require('config.autocmds')
require('config.autoreload').setup()
_G.reload_events = {}
vim.api.nvim_create_autocmd('FileChangedShellPost', { callback = function(args)
  table.insert(_G.reload_events, { buf = args.buf, modified = vim.bo[args.buf].modified })
end })
]],
		root
	)
	local clean = base .. "/clean.txt"
	write(clean, { "original" })
	open(clean)
	write(clean, { "saved buffer receives external content" })
	wait_for(
		"return vim.api.nvim_get_current_line() == 'saved buffer receives external content'",
		"clean reload failed"
	)
	assert(not lua("return vim.bo.modified"))
	pass("saved buffer reloads without focusing the editor")

	write(clean .. ".new", { "atomic replacement" })
	assert(vim.uv.fs_rename(clean .. ".new", clean))
	wait_for("return vim.api.nvim_get_current_line() == 'atomic replacement'", "atomic reload failed")
	write(clean, { "another change after atomic replacement" })
	wait_for(
		"return vim.api.nvim_get_current_line() == 'another change after atomic replacement'",
		"watch was lost after rename"
	)
	pass("atomic replacement reloads and subsequent changes remain watched")

	lua("vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'my unsaved edit' }); _G.reload_events = {}")
	write(clean, { "conflicting external content on disk" })
	wait_for("return #_G.reload_events > 0", "external conflict was not handled")
	assert(lua("return vim.bo.modified and vim.api.nvim_get_current_line() == 'my unsaved edit'"))
	assert(vim.deep_equal(vim.fn.readfile(clean), { "conflicting external content on disk" }))
	pass("external conflict preserves unsaved buffer and external disk content")
	local messages = lua("return vim.api.nvim_exec2('messages', { output = true }).output")
	assert(messages:find("Unsaved edits kept.", 1, true))
	assert(not messages:find("Buffer reloaded.", 1, true))

	lua("vim.cmd('edit!')")
	assert(
		lua("return not vim.bo.modified and vim.api.nvim_get_current_line() == 'conflicting external content on disk'")
	)
	write(clean, { "reload works after discarding the edit explicitly" })
	wait_for(
		"return vim.api.nvim_get_current_line() == 'reload works after discarding the edit explicitly'",
		"reload after conflict failed"
	)
	pass("explicit conflict resolution restores normal reload behavior")

	local created = base .. "/created.txt"
	vim.fn.delete(created)
	open(created)
	lua("vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'newly saved file' }); vim.cmd.write()")
	write(created, { "external content after first save" })
	wait_for(
		"return vim.api.nvim_get_current_line() == 'external content after first save'",
		"first save did not attach a watch"
	)
	pass("saving a new file starts watching it")

	local buf = lua("return vim.api.nvim_get_current_buf()")
	lua("vim.cmd('bwipeout!')")
	write(created, { "external content after closing the buffer" })
	vim.wait(100, function()
		return false
	end)
	assert(not lua("return vim.api.nvim_buf_is_valid(...)", buf))
	pass("wiping a buffer tolerates later filesystem changes")

	-- Deliver a callback after its watcher has been retired, as can happen
	-- between libuv's event delivery and the scheduled main-loop callback.
	lua(
		[[
local path = ...
local original = vim.uv.new_fs_event
local handles = {}
vim.uv.new_fs_event = function()
  local handle = { closed = false }
  function handle:start(_, _, callback) self.callback = callback; return 0 end
  function handle:stop() self.active = false end
  function handle:is_closing() return self.closed end
  function handle:close() self.closed = true end
  handles[#handles + 1] = handle
  return handle
end
vim.cmd.edit(vim.fn.fnameescape(path))
local old = handles[#handles]
require('config.autoreload').start()
assert(old.closed)
local count = #handles
old.callback(nil)
vim.wait(20, function() return false end)
assert(#handles == count, 'obsolete callback replaced the active watcher')
local current = handles[#handles]
local buf = vim.api.nvim_get_current_buf()
vim.cmd.enew()
vim.api.nvim_buf_delete(buf, { unload = true })
assert(vim.api.nvim_buf_is_valid(buf) and not vim.api.nvim_buf_is_loaded(buf))
assert(current.closed)
current.callback(nil)
vim.wait(20, function() return false end)
require('config.autoreload').start(buf)
assert(#handles == count, 'a retired callback reopened an unloaded buffer watcher')
vim.uv.new_fs_event = original
]],
		clean
	)
	pass("retired callbacks cannot replace a watcher or revive an unloaded buffer")
end, debug.traceback)
pcall(vim.rpcnotify, child, "nvim_command", "qa!")
vim.fn.jobwait({ child }, 1000)
vim.fn.jobstop(child)
if not ok then
	error(err)
end
print("PASS: " .. count .. " Neovim checks (6 real filesystem, 1 delayed callback)")
