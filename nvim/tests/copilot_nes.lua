-- Run with: NVIM_LOG_FILE=/dev/null nvim --headless -u NONE -i NONE -n -l tests/copilot_nes.lua
local root = vim.fn.getcwd()
vim.env.XDG_STATE_HOME = root .. "/.agent/copilot-check/state"
vim.opt.runtimepath:append(root)
local dependency = vim.fn.expand("~/.local/share/nvim/lazy/copilot-lsp")
if vim.fn.isdirectory(dependency) == 0 then
	dependency = root .. "/.agent/copilot-check/copilot-lsp-source"
end
assert(vim.fn.isdirectory(dependency) == 1, "Install copilot-lsp before running this test")
vim.opt.runtimepath:append(dependency)
vim.o.virtualedit = "onemore"
vim.lsp.log.set_level(vim.log.levels.OFF)

local ghost_visible, ghost_available, accepted_commands = false, true, {}
local fake_client = {
	id = 123,
	attached_buffers = {},
	exec_cmd = function(_, command, context)
		accepted_commands[#accepted_commands + 1] = { command = command, context = context }
	end,
}
package.loaded["copilot.suggestion"] = {
	clear_preview = function()
		ghost_visible = false
	end,
	update_preview = function()
		ghost_visible = ghost_available and not vim.b.copilot_suggestion_hidden
	end,
	dismiss = function()
		ghost_available, ghost_visible = false, false
	end,
}
package.loaded["copilot.client"] = {
	get = function()
		return fake_client
	end,
}

local nes = require("config.copilot_nes")
nes.setup()
local ui = require("copilot-lsp.nes.ui")
local namespace = vim.api.nvim_create_namespace("copilot-nes-test")
local count, fixture = 0, 0
local function check(name, fn)
	fn()
	count = count + 1
	print("PASS " .. name)
end
local function drain()
	vim.wait(20, function()
		return false
	end)
end
local function prepare(lines)
	fixture = fixture + 1
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_set_current_buf(buf)
	vim.api.nvim_buf_set_name(buf, root .. "/.agent/copilot-check/nes-test-" .. fixture .. ".txt")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines or { "old", "tail" })
	vim.lsp.util.buf_versions[buf] = 10
	fake_client.attached_buffers[buf] = true
	ghost_available, ghost_visible = true, true
	accepted_commands = {}
	return buf
end
local function edit(buf, text, range)
	return {
		textDocument = { uri = vim.uri_from_bufnr(buf), version = vim.lsp.util.buf_versions[buf] },
		text = text or "new",
		newText = text or "new",
		range = range or { start = { line = 0, character = 0 }, ["end"] = { line = 0, character = 3 } },
		command = { command = "test.accept", title = "Accept", arguments = { fixture } },
	}
end
local function show(buf, candidate)
	return ui._display_next_suggestion(buf, namespace, { candidate or edit(buf) })
end
local function lines(buf)
	return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

check("setup is idempotent", function()
	local display = ui._display_next_suggestion
	local autocmds = #vim.api.nvim_get_autocmds({ group = "CopilotNesDocument" })
	nes.setup()
	assert(display == ui._display_next_suggestion)
	assert(autocmds == #vim.api.nvim_get_autocmds({ group = "CopilotNesDocument" }))
end)

check("fresh preview suppresses ghost and clear restores it", function()
	local buf = prepare()
	assert(show(buf))
	assert(#vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, {}) > 0)
	assert(vim.b[buf].copilot_suggestion_hidden and not ghost_visible)
	assert(nes.clear())
	assert(not vim.b[buf].copilot_suggestion_hidden and ghost_visible)
	assert(vim.b[buf].nes_state == nil)
	assert(not nes.clear())
end)

check("a whole-line continuation appears inline without repeating typed text", function()
	local buf = prepare({ "err := apply" })
	local candidate = edit(buf, "err := applyThreshold(items)", {
		start = { line = 0, character = 0 },
		["end"] = { line = 0, character = 12 },
	})
	local original = vim.deepcopy(candidate)
	assert(show(buf, candidate))
	local marks = vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, { details = true })
	assert(#marks == 1 and marks[1][3] == 12)
	assert(marks[1][4].virt_text_pos == "inline")
	assert(vim.deep_equal(marks[1][4].virt_text, { { "Threshold(items)", "CopilotSuggestion" } }))
	assert(vim.deep_equal(candidate, original) and lines(buf)[1] == "err := apply")
	assert(nes.accept())
	drain()
	assert(lines(buf)[1] == "err := applyThreshold(items)")
end)

check("an insertion before an unchanged suffix shows only the missing text", function()
	local buf = prepare({ "call()" })
	assert(show(
		buf,
		edit(buf, "call(value)", {
			start = { line = 0, character = 0 },
			["end"] = { line = 0, character = 6 },
		})
	))
	local marks = vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, { details = true })
	assert(#marks == 1 and marks[1][3] == 5)
	assert(marks[1][4].virt_text[1][1] == "value")
end)

check("preview trimming preserves Unicode characters with shared UTF-8 bytes", function()
	for _, replacement in ipairs({ "ê", "ũ", "éa" }) do
		local buf = prepare({ "é" })
		assert(show(
			buf,
			edit(buf, replacement, {
				start = { line = 0, character = 0 },
				["end"] = { line = 0, character = 1 },
			})
		))
		assert(nes.accept())
		drain()
		assert(lines(buf)[1] == replacement)
	end
end)

check("multiline continuations start inline and continue as plain ghost lines", function()
	local buf = prepare({ "call" })
	assert(show(
		buf,
		edit(buf, "call(a,\n  b)", {
			start = { line = 0, character = 0 },
			["end"] = { line = 0, character = 4 },
		})
	))
	local marks = vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, { details = true })
	assert(#marks == 2)
	local inline, extra
	for _, mark in ipairs(marks) do
		inline = mark[4].virt_text or inline
		extra = mark[4].virt_lines or extra
	end
	assert(vim.deep_equal(inline, { { "(a,", "CopilotSuggestion" } }))
	assert(vim.deep_equal(extra, { { { "  b)", "CopilotSuggestion" } } }))
	assert(nes.accept())
	drain()
	assert(vim.deep_equal(lines(buf), { "call(a,", "  b)" }))
end)

check("upstream clear also restores the previous hidden flag", function()
	local buf = prepare()
	vim.b[buf].copilot_suggestion_hidden = true
	assert(show(buf))
	ui.clear_suggestion(buf, namespace)
	assert(vim.b[buf].copilot_suggestion_hidden == true)
	assert(not ghost_visible and vim.b[buf].nes_state == nil)
end)

check("stale, wrong URI, unversioned and empty replies preserve a newer preview", function()
	local buf = prepare()
	assert(show(buf))
	for _, change in ipairs({ { version = 9 }, { uri = "file:///other" }, { version = false } }) do
		local candidate = edit(buf, "bad")
		for key, value in pairs(change) do
			if value == false then
				candidate.textDocument[key] = nil
			else
				candidate.textDocument[key] = value
			end
		end
		assert(not show(buf, candidate))
		assert(vim.b[buf].nes_state.newText == "new")
	end
	assert(not ui._display_next_suggestion(buf, namespace, {}))
	local invalid_second = edit(buf)
	invalid_second.textDocument.version = 9
	assert(not ui._display_next_suggestion(buf, namespace, { edit(buf), invalid_second }))
	assert(vim.b[buf].nes_state.newText == "new")
end)

check("changed text rejects acceptance before TextChanged is delivered", function()
	local buf = prepare()
	assert(show(buf))
	vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "typed" })
	assert(not nes.accept())
	drain()
	assert(lines(buf)[1] == "typed" and vim.b[buf].nes_state == nil)
	assert(not vim.b[buf].copilot_suggestion_hidden)
end)

check("text change event clears the preview", function()
	local buf = prepare()
	assert(show(buf))
	vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "typed" })
	vim.api.nvim_exec_autocmds("TextChangedP", { buffer = buf })
	assert(vim.b[buf].nes_state == nil)
	assert(#vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, {}) == 0)
end)

check("select mode leaves snippet Tab available", function()
	local buf = prepare()
	assert(show(buf))
	local get_mode = vim.api.nvim_get_mode
	vim.api.nvim_get_mode = function()
		return { mode = "s", blocking = false }
	end
	local handled = nes.accept()
	vim.api.nvim_get_mode = get_mode
	assert(not handled and vim.b[buf].nes_state)
	assert(lines(buf)[1] == "old")
end)

check("normal acceptance consumes repeated Tab once and sends acceptance telemetry", function()
	local buf = prepare()
	assert(show(buf))
	local fallbacks = 0
	for _ = 1, 2 do
		if not nes.accept() then
			fallbacks = fallbacks + 1
		end
	end
	assert(fallbacks == 0)
	drain()
	assert(lines(buf)[1] == "new" and #lines(buf) == 2)
	assert(#accepted_commands == 1 and accepted_commands[1].context.bufnr == buf)
	assert(not ghost_visible and not vim.b[buf].copilot_suggestion_hidden)
	assert(vim.b[buf].nes_state == nil and not nes.accept())
end)

check("buffer change before scheduled application cannot edit either buffer", function()
	local buf = prepare()
	assert(show(buf) and nes.accept())
	local other = prepare({ "other" })
	drain()
	assert(lines(buf)[1] == "old" and lines(other)[1] == "other")
	assert(#accepted_commands == 0)
	assert(not show(buf, edit(buf)), "inactive-buffer response must not reappear")
end)

check("window change before scheduled application rejects the edit even without WinLeave", function()
	local buf = prepare()
	assert(show(buf) and nes.accept())
	vim.cmd("noautocmd split")
	drain()
	assert(lines(buf)[1] == "old" and vim.b[buf].nes_state == nil)
	vim.cmd("close")
end)

check("text entered before scheduled application is preserved", function()
	local buf = prepare()
	assert(show(buf) and nes.accept())
	vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "new input" })
	drain()
	assert(lines(buf)[1] == "new input" and #accepted_commands == 0)
end)

check("scheduled acceptance rechecks URI, document version and modifiability", function()
	for _, change in ipairs({ "uri", "version", "modifiable" }) do
		local buf = prepare()
		assert(show(buf) and nes.accept())
		if change == "uri" then
			vim.api.nvim_buf_set_name(buf, root .. "/.agent/copilot-check/renamed-" .. fixture .. ".txt")
		elseif change == "version" then
			vim.lsp.util.buf_versions[buf] = 11
		else
			vim.bo[buf].modifiable = false
		end
		drain()
		assert(lines(buf)[1] == "old" and #accepted_commands == 0, change)
		assert(vim.b[buf].nes_state == nil, change)
	end
end)

check("moving beyond the upstream distance threshold clears NES", function()
	local content = {}
	for i = 1, 100 do
		content[i] = i == 1 and "old" or "line " .. i
	end
	local buf = prepare(content)
	assert(show(buf))
	vim.api.nvim_win_set_cursor(0, { 80, 0 })
	vim.api.nvim_exec_autocmds("CursorMoved", { buffer = buf })
	assert(vim.b[buf].nes_state == nil and not nes.accept())
	drain()
	assert(lines(buf)[1] == "old")
	-- Also guard a mapping run before CursorMoved has been delivered.
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	assert(show(buf))
	vim.api.nvim_win_set_cursor(0, { 80, 0 })
	assert(not nes.accept() and vim.b[buf].nes_state == nil)
end)

check("an offscreen edit within 40 lines cannot consume normal Tab", function()
	local content = {}
	for i = 1, 60 do
		content[i] = i == 1 and "old" or "line " .. i
	end
	local buf = prepare(content)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	vim.cmd("normal! zt")
	assert(show(buf))
	vim.api.nvim_win_set_cursor(0, { 20, 0 })
	vim.cmd("normal! zt")
	vim.cmd("redraw")
	assert(vim.fn.line("w0") > 1, "fixture must put the edit above the real window view")
	assert(math.abs(vim.api.nvim_win_get_cursor(0)[1] - 1) < 40)
	assert(not nes.accept() and vim.b[buf].nes_state == nil)
	drain()
	assert(lines(buf)[1] == "old" and vim.api.nvim_win_get_cursor(0)[1] == 20)
end)

check("a candidate concealed inside a closed fold cannot consume Tab", function()
	local buf = prepare({ "one", "two", "old", "four", "five", "six" })
	local range = { start = { line = 2, character = 0 }, ["end"] = { line = 2, character = 3 } }
	vim.wo.foldmethod = "manual"
	assert(show(buf, edit(buf, "new", range)))
	vim.cmd("2,5fold")
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	assert(vim.fn.foldclosed(3) == 2)
	assert(not nes.accept())
	drain()
	assert(lines(buf)[3] == "old")
	vim.cmd("normal! zE")
end)

check("detach clears a pending preview and rejects delayed replies", function()
	local buf = prepare()
	assert(show(buf) and nes.accept())
	fake_client.attached_buffers[buf] = nil
	vim.api.nvim_exec_autocmds("LspDetach", { buffer = buf, data = { client_id = fake_client.id } })
	assert(vim.b[buf].nes_state == nil and not vim.b[buf].copilot_suggestion_hidden)
	assert(not show(buf, edit(buf)))
	drain()
	assert(lines(buf)[1] == "old" and #accepted_commands == 0)
end)

check("new candidate generation invalidates an already queued acceptance", function()
	local buf = prepare()
	assert(show(buf, edit(buf, "first")) and nes.accept())
	assert(show(buf, edit(buf, "second")))
	drain()
	assert(lines(buf)[1] == "old" and vim.b[buf].nes_state.newText == "second")
	assert(nes.accept())
	drain()
	assert(lines(buf)[1] == "second" and #accepted_commands == 1)
end)

check("UTF-16 replacement preserves emoji and Japanese byte boundaries", function()
	local buf = prepare({ "a😀あb" })
	local candidate = edit(buf, "字", { start = { line = 0, character = 1 }, ["end"] = { line = 0, character = 4 } })
	assert(show(buf, candidate))
	local marks = vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, { details = true })
	local preview_text = ""
	for _, mark in ipairs(marks) do
		for _, line in ipairs(mark[4].virt_lines or {}) do
			for _, chunk in ipairs(line) do
				preview_text = preview_text .. chunk[1]
			end
		end
	end
	assert(preview_text == "a字b", preview_text)
	assert(candidate.range["end"].character == 4 and vim.b[buf].nes_state.range["end"].character == 4)
	assert(nes.accept())
	drain()
	assert(lines(buf)[1] == "a字b")
	assert(vim.api.nvim_win_get_cursor(0)[2] == #"a字")
end)

check("UTF-16 inline preview uses a byte column and multiline acceptance ends at inserted text", function()
	local buf = prepare({ "😀あ tail" })
	local range = { start = { line = 0, character = 3 }, ["end"] = { line = 0, character = 3 } }
	assert(show(buf, edit(buf, "X", range)))
	local marks = vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, {})
	assert(marks[1][3] == #"😀あ")
	assert(show(buf, edit(buf, "\n日本", range)) and nes.accept())
	drain()
	assert(vim.deep_equal(lines(buf), { "😀あ", "日本 tail" }))
	assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 2, #"日本" }))
end)

check("EOF insertion remains acceptable at its visible preview anchor", function()
	local buf = prepare({ "old" })
	local range = { start = { line = 1, character = 0 }, ["end"] = { line = 1, character = 0 } }
	assert(show(buf, edit(buf, "new\n", range)))
	assert(nes.accept())
	drain()
	assert(vim.deep_equal(lines(buf), { "old", "new" }))
	assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 2, 3 }))
end)

check("configured Blink Tab stops after NES, keeps snippet fallback and Enter acceptance", function()
	vim.opt.runtimepath:append(vim.fn.expand("~/.local/share/nvim/lazy/blink.cmp"))
	local spec = dofile(root .. "/lua/plugins/blink.lua")
	require("blink.cmp.config").merge_with({ keymap = spec.opts.keymap })
	local cmp = require("blink.cmp")
	local snippets, completions = 0, 0
	cmp.snippet_forward = function()
		snippets = snippets + 1
		return true
	end
	cmp.accept = function()
		completions = completions + 1
		return true
	end
	package.loaded["copilot.suggestion"].is_visible = function()
		return ghost_visible
	end
	package.loaded["copilot.suggestion"].accept = function()
		error("NES preview must suppress the regular ghost")
	end
	local mappings = require("blink.cmp.keymap").get_mappings(spec.opts.keymap, "default")
	local buf = prepare()
	require("blink.cmp.keymap.apply").keymap_to_current_buffer({
		["<Tab>"] = mappings["<Tab>"],
		["<CR>"] = mappings["<CR>"],
	})
	assert(show(buf))
	local tab = vim.fn.maparg("<Tab>", "i", false, true).callback
	assert(tab() == nil and snippets == 0 and completions == 0)
	drain()
	assert(lines(buf)[1] == "new")
	assert(tab() == nil and snippets == 1)
	assert(vim.fn.maparg("<CR>", "i", false, true).callback() == nil and completions == 1)
end)

check("native insert input and NES acceptance have separate undo entries", function()
	local child = vim.fn.jobstart(
		{ vim.v.progpath, "--headless", "--embed", "-u", "NONE", "-i", "NONE", "-n" },
		{ rpc = true }
	)
	assert(child > 0)
	local function rpc(method, ...)
		return vim.fn.rpcrequest(child, method, ...)
	end
	local ok, err = pcall(function()
		rpc(
			"nvim_exec_lua",
			[[
local root, dependency = ...
vim.opt.runtimepath:append(root)
vim.opt.runtimepath:append(dependency)
vim.api.nvim_buf_set_name(0, root .. "/.agent/copilot-check/nes-undo.txt")
local client = { attached_buffers = { [vim.api.nvim_get_current_buf()] = true } }
package.loaded["copilot.client"] = { get = function() return client end }
require("config.copilot_nes").setup()
vim.keymap.set("i", "<Tab>", function()
  return require("config.copilot_nes").accept() and "" or "<Tab>"
end, { expr = true })
		]],
			{ root, dependency }
		)
		rpc("nvim_input", "iabc")
		assert(vim.wait(500, function()
			return rpc("nvim_get_current_line") == "abc"
		end))
		rpc(
			"nvim_exec_lua",
			[[
local buf = vim.api.nvim_get_current_buf()
vim.lsp.util.buf_versions[buf] = 1
assert(require("copilot-lsp.nes.ui")._display_next_suggestion(buf, vim.api.nvim_create_namespace("nes-undo"), {
  { newText = "XYZ", textDocument = { uri = vim.uri_from_bufnr(buf), version = 1 },
    range = { start = { line = 0, character = 3 }, ["end"] = { line = 0, character = 3 } } }
}))
		]],
			{}
		)
		rpc("nvim_input", "<Tab>")
		assert(vim.wait(500, function()
			return rpc("nvim_get_current_line") == "abcXYZ"
		end))
		rpc("nvim_input", "<Esc>u")
		assert(
			vim.wait(500, function()
				return rpc("nvim_get_current_line") == "abc"
			end),
			"undo removed the user's text along with the NES edit"
		)
	end)
	vim.fn.jobstop(child)
	assert(ok, err)
end)

assert(#vim.lsp.get_clients() == 0, "tests must not start a language server")
print("PASS: " .. count .. " Copilot NES regression checks (upstream UI, fake client)")
