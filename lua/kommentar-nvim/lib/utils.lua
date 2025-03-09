local utils = {}
local Config = require('kommentar-nvim.config').config
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

--- Get unmodified commentstring from `vim.bo.commentstring`
function utils.get_commentstring()	local commentstring = vim.bo.commentstring

	-- look for user commentstring
	if Config.user_config.comment_strings[vim.bo.filetype] then
		return Config.user_config.comment_strings[vim.bo.filetype]
	end

	local result = ''
	-- the patterns to :gsub the commentstring with
	-- not in use right now
	local lua_gsub_patterns = {
		' %%s', -- for lua, py ...
	}

	-- find the right pattern and apply it
	for _, gsub_pattern in pairs(lua_gsub_patterns) do
		local formated_commentstring, n = string.gsub(vim.bo.commentstring, gsub_pattern, '')
		if n > 0 then
			result = formated_commentstring
			break
		end
	end

	return result
end
return utils
