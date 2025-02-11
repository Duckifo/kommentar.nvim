-- get version command
vim.api.nvim_create_user_command('ScdVersion', function()
	print('Current Version Of `Scd.nvim` -- (requires `git`)\n:' .. require('scd-nvim.version').get_local_version())
end, {})


-- Create new user command, for creating new divider at current cursor.pos and buffer
vim.api.nvim_create_user_command("ScdCreateDivider", function(args_string)
	--[[ Args:
			 [1] -> len:			int
			 [2] -> label: 			string
			 [3] -> format: 		string
			 [4] -> debug:			bool
		]]

	-- make args into an table split by `;`
	local args = require('scd-nvim.utils').split(args_string.args, ';')

	local length = tonumber(args[1])
	local format = args[3]:lower()
	local label = args[2]

	-- Create divider
	require('scd-nvim.core').create_divider(label, length, format)
end, { nargs = '*' })
