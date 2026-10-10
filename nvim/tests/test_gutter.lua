-- Run: NVIM_LOG_FILE=/dev/null nvim --headless -u NONE -i NONE -n -l tests/test_gutter.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local calls, positions = {}, {}
local function tree(items, children)
	local root = {
		data = function()
			return items[1]
		end,
	}
	local nodes = { root }
	for index = 2, #items do
		local item = items[index]
		nodes[#nodes + 1] = {
			data = function()
				return item
			end,
		}
	end
	for _, child in ipairs(children or {}) do
		for _, node in child:iter_nodes() do
			nodes[#nodes + 1] = node
		end
	end
	root.iter_nodes = function()
		return ipairs(nodes)
	end
	return root
end

package.loaded.neotest = {
	state = {
		adapter_ids = function()
			return { "go:/worktree-a", "rust:/worktree-b" }
		end,
		positions = function(adapter, opts)
			return positions[adapter] and positions[adapter][opts.buffer]
		end,
	},
	run = {
		run = function(args)
			calls[#calls + 1] = { "run", args }
		end,
	},
	output = {
		open = function(args)
			calls[#calls + 1] = { "output", args }
		end,
	},
}

local gutter = require("config.test_gutter")
local function eq(expected, actual)
	assert(vim.deep_equal(expected, actual), "expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
end
local function flush()
	-- Process callbacks without starting a test runner.
	local done = false
	vim.schedule(function()
		done = true
	end)
	assert(vim.wait(1000, function()
		return done
	end))
end

local active_win = vim.api.nvim_get_current_win()
local active_buf = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(active_buf, 0, -1, false, { "active buffer" })
vim.cmd.vsplit()
local test_win = vim.api.nvim_get_current_win()
local test_buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_win_set_buf(test_win, test_buf)
vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, {
	"mod tests {",
	"    #[test]",
	"    fn first() {}",
	"",
	"    #[test]",
	"    fn second() {}",
	"}",
})
vim.bo[test_buf].modified = false
vim.api.nvim_win_set_cursor(test_win, { 6, 0 })
vim.api.nvim_set_current_win(active_win)

positions["rust:/worktree-b"] = {
	[test_buf] = tree({
		{ id = "file", type = "file", range = { 0, 0, 7, 0 } },
		{ id = "module", type = "namespace", range = { 0, 0, 6, 1 } },
		{ id = "first", type = "test", range = { 1, 0, 2, 18 } },
		{ id = "second", type = "test", range = { 4, 0, 5, 19 } },
	}),
}
vim.fn.sign_define("neotest_test", { text = ">", texthl = "Normal" })
vim.fn.sign_define("neotest_namespace", { text = "N", texthl = "Normal" })
vim.fn.sign_place(1, "neotest-status", "neotest_test", test_buf, { lnum = 2 })
vim.fn.sign_place(2, "neotest-status", "neotest_test", test_buf, { lnum = 5 })
vim.fn.sign_place(3, "neotest-status", "neotest_namespace", test_buf, { lnum = 1 })

local function click(line, button, count, win)
	gutter.handle_click({
		clicks = count or 1,
		button = button or "l",
		mods = "",
		mousepos = { winid = win or test_win, line = line },
	})
end

-- An inactive split, and then a buffer change before scheduled execution, must
-- still run the exact test and adapter captured by the click.
click(2)
eq(active_win, vim.api.nvim_get_current_win())
eq({ 6, 0 }, vim.api.nvim_win_get_cursor(test_win))
vim.api.nvim_win_set_buf(test_win, active_buf)
flush()
eq({ { "run", { "first", adapter = "rust:/worktree-b" } } }, calls)
vim.api.nvim_win_set_buf(test_win, test_buf)

calls = {}
click(5, "r")
flush()
eq({ { "output", { position_id = "second", adapter = "rust:/worktree-b", enter = true } } }, calls)

-- Do not infer a nearest test from blank rows or from namespace/file markers.
calls = {}
click(1)
click(3)
click(0)
click(99)
click(2, "m")
click(2, "l", 2)
click(2, "r", 2)
click(2, "l", 1, 999999)
flush()
eq({}, calls)

-- An undiscovered/stale marker cannot accidentally launch a file or suite.
vim.fn.sign_unplace("neotest-status", { buffer = test_buf, id = 1 })
click(2)
vim.fn.sign_place(4, "neotest-status", "neotest_test", test_buf, { lnum = 4 })
click(4)
flush()
eq({}, calls)

-- Ambiguous positions on the same source row must not pick an arbitrary test.
positions["go:/worktree-a"] = {
	[test_buf] = tree({ { id = "also_second", type = "test", range = { 4, 0, 5, 19 } } }),
}
click(5)
flush()
eq({}, calls)
positions["go:/worktree-a"] = nil

-- Insertions move signs immediately, while discovered ranges still describe
-- the saved file. A moved first-test sign must never run the cached second test.
local original_positions = positions["rust:/worktree-b"][test_buf]
positions["rust:/worktree-b"][test_buf] = tree({
	{ id = "first", type = "test", range = { 2, 0, 3, 0 } },
	{ id = "second", type = "test", range = { 4, 0, 5, 0 } },
})
vim.fn.sign_place(1, "neotest-status", "neotest_test", test_buf, { lnum = 3 })
vim.api.nvim_buf_set_lines(test_buf, 0, 0, false, { "", "" })
eq(5, vim.fn.sign_getplaced(test_buf, { group = "neotest-status", id = 1 })[1].signs[1].lnum)
click(5)
click(5, "r")
flush()
eq({}, calls)
vim.api.nvim_buf_set_lines(test_buf, 0, 2, false, {})
vim.bo[test_buf].modified = false
vim.fn.sign_unplace("neotest-status", { buffer = test_buf, id = 1 })
positions["rust:/worktree-b"][test_buf] = original_positions

-- A real double-click sequence invokes the action only for its first click.
click(5, "l", 1)
click(5, "l", 2)
flush()
eq({ { "run", { "second", adapter = "rust:/worktree-b" } } }, calls)

vim.api.nvim_win_close(test_win, true)
calls = {}
click(5)
flush()
eq({}, calls)
print("test_gutter: click targeting and guards passed")

-- Set STATUSCOL_RTP to a statuscol.nvim checkout to verify the real renderer.
if vim.env.STATUSCOL_RTP then
	vim.opt.runtimepath:append(vim.env.STATUSCOL_RTP)
	dofile("lua/plugins/statuscol.lua").config()
	vim.wo.number = true
	vim.api.nvim_buf_set_lines(active_buf, 0, -1, false, { "mod tests {", "#[test]", "fn works() {}", "}" })
	vim.fn.sign_define("GitExample", { text = "|", texthl = "Normal" })
	vim.fn.sign_place(1, "neotest-status", "neotest_test", active_buf, { lnum = 2, priority = 1000 })
	vim.fn.sign_place(1, "git", "GitExample", active_buf, { lnum = 2, priority = 199 })
	local rendered = vim.api.nvim_eval_statusline(vim.wo.statuscolumn, { winid = active_win, use_statuscol_lnum = 2 })
	assert(rendered.str:find("|", 1, true), "Git sign hidden by test sign")
	assert(rendered.str:find(">", 1, true), "Test sign hidden by Git sign")
	assert(rendered.str:match("2%s*$"), "Line number not rendered")
	print("test_gutter: real statuscol rendering passed: " .. rendered.str)
end

-- Set NEOTEST_RTP to test popup switching against the real output consumer.
-- Its sibling nvim-nio and plenary.nvim dependencies must also be installed.
if vim.env.NEOTEST_RTP then
	local plugins = vim.fn.fnamemodify(vim.env.NEOTEST_RTP, ":h")
	for _, path in ipairs({ vim.env.NEOTEST_RTP, plugins .. "/nvim-nio", plugins .. "/plenary.nvim" }) do
		vim.opt.runtimepath:append(path)
	end
	require("neotest.config").setup({ output = { open_on_run = false } })
	local looked_up = {}
	local client = {
		listeners = {},
		get_position = function(_, id)
			looked_up[#looked_up + 1] = id
			return {
				data = function()
					return { id = id, name = id }
				end,
			}, "rust:/worktree-b"
		end,
		get_results = function()
			return {
				first = { output = "lua/config/test_gutter.lua" },
				second = { output = "lua/plugins/statuscol.lua" },
			}
		end,
	}
	package.loaded.neotest.output = require("neotest.consumers.output")(client)
	test_win = active_win
	vim.api.nvim_set_current_win(test_win)
	vim.api.nvim_win_set_buf(test_win, test_buf)
	vim.fn.sign_place(1, "neotest-status", "neotest_test", test_buf, { lnum = 2 })
	local function output_text()
		if vim.bo.filetype ~= "neotest-output" then
			return ""
		end
		return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	end
	click(2, "r")
	assert(
		vim.wait(3000, function()
			return output_text():find("function M.handle_click", 1, true) ~= nil
		end),
		"First popup did not open"
	)
	local first_popup = vim.api.nvim_get_current_win()
	-- The first popup remains focused when clicking another test's gutter.
	click(5, "r")
	assert(
		vim.wait(3000, function()
			return output_text():find("luukvbaal/statuscol.nvim", 1, true) ~= nil
		end),
		"Second click kept the first test's output"
	)
	eq({ "first", "second" }, looked_up)
	assert(not vim.api.nvim_win_is_valid(first_popup), "Old popup was not closed")
	print("test_gutter: real output popup switches between clicked tests")
end

-- Save/discovery/state updates are asynchronous: reject old snapshots during
-- both gaps, and accept the newly discovered tree once the public state agrees.
test_win = active_win
vim.api.nvim_set_current_win(test_win)
vim.api.nvim_win_set_buf(test_win, test_buf)
vim.api.nvim_buf_set_name(test_buf, vim.fn.getcwd() .. "/test-gutter-fixture.rs")
local client = {
	listeners = {},
	get_adapters = function()
		return {}
	end,
}
local nio = package.loaded.nio
package.loaded.nio = {
	run = function(fn)
		fn()
	end,
}
gutter.init(client)
flush()
package.loaded.nio = nio
calls = {}
click(5)
flush()
eq({}, calls)
original_positions.data = function()
	return { type = "file", path = vim.api.nvim_buf_get_name(test_buf) }
end
-- Open-buffer discovery initially wraps the same file node in a directory tree.
local directory = tree({ { type = "dir", path = vim.fn.getcwd() } }, { original_positions })
client.listeners.discover_positions("rust:/worktree-b", directory)
click(5)
flush()
eq({ { "run", { "second", adapter = "rust:/worktree-b" } } }, calls)
calls = {}
vim.api.nvim_buf_set_lines(test_buf, 3, 4, false, { "// saved edit" })
vim.bo[test_buf].modified = false
click(5)
flush()
eq({}, calls)
local fresh = tree({
	original_positions:data(),
	{ id = "updated_second", type = "test", range = { 4, 0, 5, 0 } },
})
client.listeners.discover_positions("rust:/worktree-b", fresh)
click(5)
flush()
eq({}, calls)
positions["rust:/worktree-b"][test_buf] = fresh
click(5)
flush()
eq({ { "run", { "updated_second", adapter = "rust:/worktree-b" } } }, calls)
print("test_gutter: discovery freshness guards passed")
