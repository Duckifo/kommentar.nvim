local utils = {}
local string_len = vim.fn.strchars

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
	for i=start_idx, string_len(string) do
		local char = string:sub(i, i)
		if char == end_char then
			return i
		end
	end

	-- no `end_paren_idx` found
	-- TODO: do proper error msg
	return nil
end

--- Splits string at `separator` char into a table
---@param str string
---@param sep string char
---@return string[]
function utils.split(str, sep)
	local result = {}
	for match in str:gmatch("([^" .. sep .. "]+)") do
		table.insert(result, match)
	end
	return result
end

return utils
