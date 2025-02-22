local utils = {}
local utf8 = require('utf8')

--- Searches for closing char from the start_idx
---```
---         "hello%(world)"
---                ↑
---        start index here
---```
---@param start_idx integer
---@param end_char string
---@param string string
---@return integer | nil
function utils.find_closing_char(start_idx, end_char, string)
	for i=start_idx, utf8.len(string) - 1 do
		local char = utf8.sub(string, i, i)
		if char == end_char then
			return i
		end
	end

	-- no `end_paren_idx` found
	-- TODO: do proper error msg
	return nil
end
return utils
