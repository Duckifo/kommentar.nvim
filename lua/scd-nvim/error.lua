--- for reporting errors 
local err = {}

---@class Prefix_t
---@field index integer
---@field line string
---@field line_nr integer

---@param t Prefix_t Table with error information
---@param msg string Message printed
err.report = function(t, msg)
	local output = 
	' Error occured, during parsing of prefix on line:' .. t.line_nr .. ('\n'):rep(2) ..
	' ' .. t.line .. ('\n'):rep(1) ..
	' ' .. (' '):rep(t.index) .. '↑' .. '\n' ..
	' ' .. msg:match(".*(%d+:.*)")

	print(output)
end

err.err_msgs = {
	['NO_CLOSING_BRACKET'] = 'No closing bracket found for parameter, HERE.',
	['NO_OPERATOR'] = 'Operator found nil, HERE.',
	['NOT_ENOUGH_ARG'] = 'Not enough arguments passed in parameter, HERE.',
	HELP_NOT_ENOUGH_ARG = {
		['=/=!/!?'] = '%(@`op` - [=,/=,!,/!,?] :@`number`:@`char` | @`chars`)',
		['c'] = '%(c:@`const_name`:@`char`?) -- char only needed if `const` is of type `int`',
		['o'] = '%(o:@`char`)'
	},
	['NO_CHAR_INCLUDED'] = 'No character included in parameter, HERE.'
}

return err
