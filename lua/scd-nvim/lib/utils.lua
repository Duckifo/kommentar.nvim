local utils = {}
local string_len = vim.fn.strchars

--- Searches for closing paren from the 
---```
---         "hello%(world)"
---                ↑
---        start index here
---```
---@param start_idx integer
---@param string string
---@return integer end_paren_index
function utils.find_closing_paren(start_idx, string)
	for i=start_idx, string_len(string) do
		local char = string:sub(i, i)
		if char == ')' then
			return i
		end
	end

	-- no `end_paren_idx` found
	-- TODO: do proper error msg
	error()
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
