-- Keep NES previews and delayed acceptance tied to the document they describe.
local M = {}
local states = {}
local setup_done = false

local function attached_client(bufnr)
	local copilot = package.loaded["copilot.client"]
	local client = copilot and copilot.get()
	return client and client.attached_buffers[bufnr] and client or nil
end

local function current_document(bufnr, edit)
	local document = edit.textDocument
	return vim.api.nvim_buf_is_valid(bufnr)
		and vim.api.nvim_buf_is_loaded(bufnr)
		and document
		and document.uri == vim.uri_from_bufnr(bufnr)
		and document.version ~= nil
		and document.version == vim.lsp.util.buf_versions[bufnr]
end

local function fresh(bufnr, state)
	return states[bufnr] == state
		and state.client == attached_client(bufnr)
		and current_document(bufnr, state.edit)
		and vim.api.nvim_buf_get_changedtick(bufnr) == state.tick
end

local function byte_position(bufnr, position)
	local line = vim.api.nvim_buf_get_lines(bufnr, position.line, position.line + 1, false)[1] or ""
	return vim.str_byteindex(line, "utf-16", position.character, true)
end

-- Servers may replace a whole line just to append text. Show only the change.
local function trim_preview(bufnr, edit)
	local first, last = edit.range.start, edit.range["end"]
	if first.line ~= last.line or last.line >= vim.api.nvim_buf_line_count(bufnr) then
		return edit
	end
	local old =
		table.concat(vim.api.nvim_buf_get_text(bufnr, first.line, first.character, last.line, last.character, {}), "\n")
	local new = edit.newText
	local prefix, suffix = 0, 0
	while prefix < math.min(#old, #new) and old:byte(prefix + 1) == new:byte(prefix + 1) do
		prefix = prefix + 1
	end
	local function continuation(byte)
		return byte and byte >= 128 and byte < 192
	end
	while prefix > 0 and continuation(old:byte(prefix + 1)) do
		prefix = prefix - 1
	end
	while suffix < math.min(#old, #new) - prefix and old:byte(#old - suffix) == new:byte(#new - suffix) do
		suffix = suffix + 1
	end
	while suffix > 0 and continuation(old:byte(#old - suffix + 1)) do
		suffix = suffix - 1
	end
	first.character = first.character + prefix
	last.character = last.character - suffix
	edit.newText = new:sub(prefix + 1, #new - suffix)
	return edit
end

local function calculate_preview(ui, bufnr, edit)
	edit = trim_preview(bufnr, edit)
	local first, last = edit.range.start, edit.range["end"]
	local line = vim.api.nvim_buf_get_lines(bufnr, first.line, first.line + 1, false)[1]
	-- A multiline continuation begins inline, with the remaining lines below it.
	if first.line == last.line and first.character == last.character and line and first.character == #line then
		local head, tail = edit.newText:match("^(.-)\n(.*)$")
		if head then
			return {
				inline_insertion = head ~= "" and { text = head, line = first.line, character = first.character }
					or nil,
				lines_insertion = { text = tail, line = first.line },
			}
		end
	end
	return ui._calculate_preview(bufnr, edit)
end

local function within_distance(state)
	local config = require("copilot-lsp.config").config.nes
	return not config.clear_on_large_distance
		or math.abs(vim.api.nvim_win_get_cursor(0)[1] - 1 - state.edit.range.start.line)
			<= config.distance_threshold
end

local function visible(state)
	-- EOF insertions are previewed on the last existing line by upstream.
	local line = math.min(state.edit.range.start.line + 1, vim.api.nvim_buf_line_count(0))
	return line >= vim.fn.line("w0") and line <= vim.fn.line("w$") and vim.fn.foldclosed(line) == -1
end

function M.clear(bufnr)
	bufnr = bufnr and bufnr > 0 and bufnr or vim.api.nvim_get_current_buf()
	local state = states[bufnr]
	if not state then
		return false
	end
	states[bufnr] = nil
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return true
	end
	vim.api.nvim_buf_clear_namespace(bufnr, state.namespace, 0, -1)
	vim.b[bufnr].nes_state = nil
	vim.b[bufnr].nes_jump = nil
	vim.b[bufnr].copilotlsp_nes_namespace_id = nil
	vim.b[bufnr].copilot_suggestion_hidden = state.hidden
	local suggestion = package.loaded["copilot.suggestion"]
	if
		suggestion
		and bufnr == vim.api.nvim_get_current_buf()
		and vim.api.nvim_buf_get_changedtick(bufnr) == state.tick
		and state.client == attached_client(bufnr)
	then
		suggestion.update_preview()
	end
	return true
end

function M.setup()
	if setup_done then
		return
	end
	local ui = require("copilot-lsp.nes.ui")
	-- Keep additions as ghost text, including multiline previews.
	require("copilot-lsp.util").hl_text_to_virt_lines = function(text)
		local lines = {}
		for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
			lines[#lines + 1] = { { line, "CopilotSuggestion" } }
		end
		return lines
	end
	local function set_highlights()
		vim.api.nvim_set_hl(0, "CopilotSuggestion", { link = "Comment", default = true })
		local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
		vim.api.nvim_set_hl(0, "CopilotLspNesDelete", { fg = comment.fg, strikethrough = true })
	end
	set_highlights()
	setup_done = true
	ui.clear_suggestion = function(bufnr)
		M.clear(bufnr)
	end
	ui._display_next_suggestion = function(bufnr, namespace, edits)
		-- Empty and outdated responses cannot erase a newer valid preview.
		local client = attached_client(bufnr)
		if not client or bufnr ~= vim.api.nvim_get_current_buf() or not edits or #edits == 0 then
			return false
		end
		for _, edit in ipairs(edits) do
			if not current_document(bufnr, edit) then
				return false
			end
		end
		local edit = vim.deepcopy(edits[1])
		edit.newText = edit.newText or edit.text
		-- Upstream preview helpers use byte columns; LSP edits must retain UTF-16.
		local preview_edit = vim.deepcopy(edit)
		local ok, preview = pcall(function()
			for _, position in pairs(preview_edit.range) do
				position.character = byte_position(bufnr, position)
			end
			return calculate_preview(ui, bufnr, preview_edit)
		end)
		if not ok or not next(preview) then
			return false
		end
		M.clear(bufnr)
		states[bufnr] = {
			client = client,
			edit = edit,
			tick = vim.api.nvim_buf_get_changedtick(bufnr),
			namespace = namespace,
			hidden = vim.b[bufnr].copilot_suggestion_hidden,
		}
		vim.b[bufnr].copilot_suggestion_hidden = true
		local suggestion = package.loaded["copilot.suggestion"]
		if suggestion then
			suggestion.clear_preview()
		end
		if not pcall(ui._display_preview, bufnr, namespace, preview) then
			M.clear(bufnr)
			return false
		end
		vim.b[bufnr].nes_state = edit
		vim.b[bufnr].copilotlsp_nes_namespace_id = namespace
		return true
	end
	local group = vim.api.nvim_create_augroup("CopilotNesDocument", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_highlights })
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
		group = group,
		callback = function(args)
			local state = states[args.buf]
			if state and not fresh(args.buf, state) then
				M.clear(args.buf)
			end
		end,
	})
	vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "BufWipeout", "LspDetach" }, {
		group = group,
		callback = function(args)
			M.clear(args.buf)
		end,
	})
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = group,
		callback = function(args)
			local state = states[args.buf]
			if state and not within_distance(state) then
				M.clear(args.buf)
			end
		end,
	})
end

function M.accept()
	local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
	if mode ~= "i" and mode ~= "n" then
		return false
	end
	local bufnr, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
	local state = states[bufnr]
	if not state then
		return false
	end
	if not fresh(bufnr, state) or not vim.bo[bufnr].modifiable or not within_distance(state) or not visible(state) then
		M.clear(bufnr)
		return false
	end
	if state.accepting then
		return true -- A second Tab must neither repeat the edit nor fall through.
	end
	state.accepting = true
	vim.schedule(function()
		if
			not fresh(bufnr, state)
			or vim.api.nvim_get_current_buf() ~= bufnr
			or vim.api.nvim_get_current_win() ~= win
			or not vim.bo[bufnr].modifiable
			or not within_distance(state)
			or not visible(state)
		then
			if states[bufnr] == state then
				M.clear(bufnr)
			end
			return
		end
		local edit = state.edit
		local lines = vim.split(edit.newText:gsub("\r\n?", "\n"), "\n", { plain = true })
		local row = edit.range.start.line + #lines
		local col = (#lines == 1 and byte_position(bufnr, edit.range.start) or 0) + #lines[#lines]
		M.clear(bufnr)
		local suggestion = package.loaded["copilot.suggestion"]
		if suggestion then
			suggestion.dismiss()
		end
		-- One undo should remove the accepted edit, preserving text typed before Tab.
		vim.cmd("let &undolevels=&undolevels")
		vim.lsp.util.apply_text_edits({ edit }, bufnr, "utf-16")
		if row > vim.api.nvim_buf_line_count(bufnr) then
			row = vim.api.nvim_buf_line_count(bufnr)
			col = #vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
		end
		col = math.min(col, #vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1])
		vim.api.nvim_win_set_cursor(win, { row, col })
		if edit.command then
			state.client:exec_cmd(edit.command, { bufnr = bufnr })
		end
	end)
	return true
end

return M
