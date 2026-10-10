-- Real-time auto-reload of buffers when their file changes on disk.
--
-- Uses libuv fs_event (event-driven, no polling) so external edits — git,
-- formatters, other editors, AI agents, etc. — are reflected immediately
-- while the buffer stays open. The FocusGained/BufEnter `checktime` in
-- autocmds.lua remains as a fallback for filesystems without fs_event support.

local M = {}

local uv = vim.uv or vim.loop
local watchers = {} -- bufnr -> uv_fs_event handle

local function stop(bufnr)
	local handle = watchers[bufnr]
	if handle then
		handle:stop()
		if not handle:is_closing() then
			handle:close()
		end
		watchers[bufnr] = nil
	end
end

local function on_change(bufnr)
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		stop(bufnr)
		return
	end
	-- Reload only this buffer (autoread does the actual reload if unmodified).
	vim.cmd("checktime " .. bufnr)
	-- Re-arm: atomic saves (write temp + rename) detach the watch from the
	-- original inode, so the handle goes silent unless we re-watch the path.
	M.start(bufnr)
end

function M.start(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		return
	end
	-- Only watch normal, file-backed buffers (skip terminals, help, etc.).
	if vim.bo[bufnr].buftype ~= "" then
		return
	end
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return
	end
	local stat = uv.fs_stat(name)
	if not stat or stat.type ~= "file" then
		return
	end

	stop(bufnr) -- replace any existing watcher for this buffer

	local handle = uv.new_fs_event()
	if not handle then
		return
	end
	watchers[bufnr] = handle
	local ok = handle:start(
		name,
		{},
		vim.schedule_wrap(function(err)
			-- A queued callback may outlive unload or replacement of this watcher.
			if err or watchers[bufnr] ~= handle then
				return
			end
			on_change(bufnr)
		end)
	)
	if not ok then
		stop(bufnr)
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("AutoReloadWatch", { clear = true })

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = group,
		callback = function(args)
			M.start(args.buf)
		end,
		desc = "Start fs_event watcher for auto-reload",
	})

	-- After our own save the path may have been replaced (rename-based write),
	-- so re-arm the watcher on the current name.
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		callback = function(args)
			M.start(args.buf)
		end,
		desc = "Re-arm fs_event watcher after save",
	})

	vim.api.nvim_create_autocmd({ "BufUnload", "BufDelete" }, {
		group = group,
		callback = function(args)
			stop(args.buf)
		end,
		desc = "Stop fs_event watcher",
	})
end

return M
