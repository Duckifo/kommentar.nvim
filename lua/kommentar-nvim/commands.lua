-- get version command
vim.api.nvim_create_user_command('KommentarVersion', function()
	print('Current Version Of `kommentar.nvim` -- (requires `git`)\n:' .. require('kommentar-nvim.lib.version').get_local_version() )
end, {})

-- Create new user command, for creating new divider at current cursor.pos and buffer
vim.api.nvim_create_user_command("CreateDivider", function(opts)
	--- get from index to index and put into a string
	local function sub_table_to_string(t, start_idx, end_idx)
		local sub = ''
		for i = start_idx, end_idx or #t do
			if i == 1 then
				sub = sub .. t[i]
			else
				sub = sub .. ' ' .. t[i]
			end
		end
		return sub
	end

	--[[ Args:
			 [1] -> format selection	
			 [2] -> len
			 [3] -> label
	]]

	-- Get args
	local args = opts.fargs

	local length = tonumber(args[2])
	local format_id = args[1]
	local label = sub_table_to_string(args, 3):sub(2) -- sub(2) as first char is always a space

	local format
	-- Check if format_id name is `@dev_format_buffer`
	if format_id == '@dev_format_buffer' then
		format = require('kommentar-nvim.dev').format_buffer
		if format == nil then
			vim.api.nvim_err_writeln('No format written to `@dev_format_buffer`')
			return
		end
	else
		format = require('kommentar-nvim.formats').formats[format_id]
		if format == nil then
			vim.api.nvim_err_writeln('Unvalid format id')
			return
		end
	end

	if not format then
		vim.api.nvim_err_writeln('Unvalid format')
		return
	end

	-- Create divider
	require('kommentar-nvim.core').create_divider_write_buf(label, length, format)
end, {
	nargs = '*',
	complete = function(arglead, cmdline, cursorpos)
		local idx = #vim.fn.split(cmdline, ' ')
		if idx == 1 then
			local options = {}
			for _, key in ipairs(require('kommentar-nvim.formats').keys) do
				table.insert(options, key)
			end
			table.insert(options, '@dev_format_buffer')
			return options
		elseif idx == 2 then
			return { '50', '75', '100', '' }
		else
			return {}
		end
	end
})
