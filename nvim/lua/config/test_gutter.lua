local M = {}
local discovered

function M.init(client)
	discovered = {}
	client.listeners.discover_positions = function(adapter, tree)
		-- With directory discovery disabled, the first file arrives wrapped in
		-- a directory tree. Record its file node as well as later file updates.
		for _, node in tree:iter_nodes() do
			local pos = node:data()
			local buf = pos.type == "file" and vim.fn.bufnr(pos.path) or -1
			if buf >= 0 and vim.api.nvim_buf_is_loaded(buf) then
				discovered[adapter] = discovered[adapter] or {}
				discovered[adapter][buf] = { tree = node, tick = vim.api.nvim_buf_get_changedtick(buf) }
			end
		end
	end
	-- Neotest starts discovery on its first client query. Start after all
	-- consumers are registered so markers appear before the first test run.
	vim.schedule(function()
		require("nio").run(function()
			client:get_adapters()
		end)
	end)
	return {}
end

function M.handle_click(args)
	if args.clicks ~= 1 or (args.button ~= "l" and args.button ~= "r") then
		return
	end
	local mouse = args.mousepos or {}
	if type(mouse.winid) ~= "number" or not vim.api.nvim_win_is_valid(mouse.winid) then
		return
	end
	local buf = vim.api.nvim_win_get_buf(mouse.winid)
	if vim.bo[buf].modified then
		vim.notify("Save the file before using test markers", vim.log.levels.INFO)
		return
	end
	if type(mouse.line) ~= "number" or mouse.line < 1 or mouse.line > vim.api.nvim_buf_line_count(buf) then
		return
	end
	local signs = vim.fn.sign_getplaced(buf, { group = "neotest-status", lnum = mouse.line })[1].signs
	if not vim.iter(signs):any(function(sign)
		return sign.name:match("^neotest_") ~= nil
	end) then
		return
	end

	local neotest = require("neotest")
	local target
	for _, adapter in ipairs(neotest.state.adapter_ids()) do
		local positions = neotest.state.positions(adapter, { buffer = buf })
		if positions then
			local known = discovered and discovered[adapter] and discovered[adapter][buf]
			if
				discovered
				and (not known or known.tree ~= positions or known.tick ~= vim.api.nvim_buf_get_changedtick(buf))
			then
				vim.notify("Test markers are updating; try again shortly", vim.log.levels.INFO)
				return
			end
			for _, node in positions:iter_nodes() do
				local pos = node:data()
				if pos.type == "test" and pos.range and pos.range[1] == mouse.line - 1 then
					-- Never guess between tests sharing a source line or adapter.
					if target then
						return
					end
					target = { id = pos.id, adapter = adapter }
				end
			end
		end
	end
	if not target then
		return
	end

	-- Capture the position before yielding: another split may gain focus while
	-- Neotest starts its asynchronous operation.
	vim.schedule(function()
		if args.button == "l" then
			neotest.run.run({ target.id, adapter = target.adapter })
		else
			if not vim.api.nvim_win_is_valid(mouse.winid) then
				return
			end
			-- Leaving the old popup closes it; otherwise Neotest reuses its
			-- contents without looking up the newly requested position.
			vim.api.nvim_set_current_win(mouse.winid)
			neotest.output.open({ position_id = target.id, adapter = target.adapter, enter = true })
		end
	end)
end

function M.click(_, clicks, button, mods)
	M.handle_click({ clicks = clicks, button = button, mods = mods, mousepos = vim.fn.getmousepos() })
end

return M
