--- For debuging format errors 
local err = {}

---@class Error_info
---@field index integer
---@field line string
---@field line_nr integer

---@param t Error_info Table with error information
---@param msg string Message printed
err.report = function(t, msg)
	local output = '\n' ..
		' Error occured, during parsing of prefix on line:' .. t.line_nr .. ('\n'):rep(2) ..
		' ' .. t.line .. ('\n'):rep(1) ..
		' ' .. (' '):rep(t.index) .. '↑' .. '\n' ..
		' ' .. msg .. '\n'

	vim.api.nvim_err_writeln(output)
end

-- TODO: find a better way
--- Used to get error message easely, think of as a match case
---``` lua
--- --  [1]: case
--- --  [2]: err msg (if case found true)
---   {char == nil, 'char found nil ...'}
---
---```
---@param ... {[1]: boolean, [2]: string}
---@return string
err.match_msg = function(...)
	for i, case in pairs({ ... }) do
		if case[1] then
			return case[2]
		end
	end
end



err.err_msgs = {
	['NO_CLOSING_PAREN'] = 'No closing paren found for parameter.',
	['NOT_ENOUGH_ARG'] = 'Not enough arguments passed in parameter.',
	['NON_VALID_OPERATOR'] = 'Non valid operator passed in parameter.',
	['NO_OPERATOR'] = 'No operator provided in parameter.',
	['NO_CHAR_INCLUDED'] = 'No character provided in parameter.',
	['NO_NUM_INCLUDED'] = 'No number value provided in parameter.',
	['UNVALID_CONST'] = 'Unvalid constant name found.',
	['UNVALID_CONST_TYPE'] = 'Unvalid const type.'
}

return err
