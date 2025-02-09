require 'scd-nvim'.setup({
	default_length = 50,
	comment_on_both_sides = true,
})

vim.keymap.set('n', '<leader>gcd1', function()
	vim.cmd('ScdCreateDivider 50;true;=%?50 < %t > =%?50')
end)  



