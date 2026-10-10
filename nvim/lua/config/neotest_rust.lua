local base = require("neotest-rust")
local adapter = vim.tbl_extend("force", {}, base)

function adapter.build_spec(args)
	local position = args.tree:data()
	if position.type ~= "file" or args.strategy == "dap" then
		return base.build_spec(args)
	end

	local filters = {}
	for _, test in args.tree:iter() do
		if test.type == "test" then
			table.insert(filters, "test(=" .. vim.fn.escape(test.id, "\\/,)") .. ")")
		end
	end
	if #filters == 0 then
		-- Neotest's file fallback visits only test nodes, so this starts no processes.
		return nil
	end

	local spec = base.build_spec(args)
	local previous = spec.context.test_filter
	local package_filter = previous and previous:match("(package%b())")
	local expression = "(" .. table.concat(filters, " | ") .. ")"
	if package_filter then
		expression = package_filter .. " & " .. expression
	end
	-- Replace only the adapter's final filter; keep package/target selection and options.
	if previous then
		assert(vim.endswith(spec.command, previous), "neotest-rust command format changed")
		spec.command = spec.command:sub(1, -#previous - 1)
	else
		spec.command = spec.command .. " "
	end
	spec.context.test_filter = "-E " .. vim.fn.shellescape(expression)
	spec.context.position_id = position.id
	spec.command = spec.command .. spec.context.test_filter
	return spec
end

return setmetatable(adapter, {
	__call = function(_, opts)
		base(opts or {})
		return adapter
	end,
})
