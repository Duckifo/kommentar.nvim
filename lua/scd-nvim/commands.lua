-- commands

-- get version command
vim.api.nvim_create_user_command('ScdVersion', function()
	print('Current Version Of `Scd.nvim`\n:'..require('scd-nvim.version').get_local_version())
end, {})
