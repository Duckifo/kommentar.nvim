--- format test will be written to tests/date-*
local M = {}
local process_format = require('kommentar-nvim.core').Proccess_pattern

--- test if divider label stays center, len doesnt change etc ...
--- does this by generating x many dividers adding one char each time its generated
---@param from integer at what repitision should the label start at, 1='a','aa'... 2='aa','aaa'...
---@param to any to what repetision should the label end at
---@param format string the format to test, not `format_id` requires raw format
---@param len integer the length of the created dividers
---@param name string | nil the name of the test, will be written to the filname of the test
M.divider_label_test = function(from, to, format, len, name)
	local buffer = ''
	local label = 'Maybe someone will write something cool here one day'

	local constants = {
		['len'] = len,
		['label'] = label,
	}

	for i=from, to do
		local processed_divider = process_format(format, {
			label=label:sub(1,i),
			consts=constants,
			length = len
		})
		buffer = buffer .. processed_divider .. '\t: (' .. 'idx: ' .. i  .. ')\n'
	end

	local 
end
