--- format test will be written to tests/date-*name*.test
local M = {}
local process_format = require('kommentar-nvim.core').Proccess_pattern

-- run with:
-- :lua require('kommentar-nvim.tests.format-test').divider_label_test(from, to, require('kommentar-nvim.formats').formats.*format*, len, *name*)

--- test if divider label stays center, len doesnt change etc ...
--- does this by generating x many dividers adding one char each time its generated
---@param from integer at what repitision should the label start at, 1='a','aa'... 2='aa','aaa'...
---@param to any to what repetision should the label end at
---@param format string the format to test, not `format_id` requires raw format
---@param len integer the length of the created dividers
---@param name string | nil the name of the test, will be written to the filname of the test
M.divider_label_test = function(from, to, format, len, name)
	local buffer = ''
	local label = 'Maybe someone will write something cool here one day, or will they? what is he purpose of this test?'
	.. ' will it solve any real problems, or just lead to more later on? giving up is the easiest way there is to life.'
	.. ' or is it? IDK, just needed a long text lol.'

	-- create the buffer
	for i=from, to do
		local processed_divider = process_format(format, {
			label=label:sub(1,i),
			consts={
				len=len,
				label=label:sub(1,i),
			},
			length = len
		})
		buffer = buffer .. processed_divider -- .. '   : (' .. 'idx: ' .. i  .. ')\n'
	end

	-- add text at top of buffer
	buffer = 'File generated with format `'.. format ..'`\n' .. buffer

	local path = require('kommentar-nvim.config').config.plugin_root .. '/tests/' .. os.date("%Y-%m-%d:%M-%S") .. '_' .. (name or 'unamed') .. '.test'

	local file, err = io.open(path, 'w')
	if not file then
		vim.api.nvim_err_writeln('Failed to open file: ' .. path .. '\n err: ' .. err)
		return
	end

	file:write(buffer)
	file:close()

	print('Successfully conducted tests! results written to: ' .. path)
end

return M
