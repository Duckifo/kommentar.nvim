local utf8 = require('utf8')

local match_msg = require('kommentar-nvim.lib.error').match_msg
local err_msgs = require('kommentar-nvim.lib.error').err_msgs

---@class Operators_opt
---@field pro_opt Proccess_Opt that got passed to proccess 
---@field const_chars integer Amount of constant characters



--- returns percent or (nil, error)
---@param args string[]
---@return number | nil, string
function get_percent( args )
	local num = tonumber(args[2])
	local char = args[3]

	if num == nil or char == nil then
		return nil, match_msg(
			{ num == nil, err_msgs['NO_NUM_INCLUDED'] },
			{ char == nil, err_msgs['NO_CHAR_INCLUDED'] }
		)
	end

	local percent = num / 100
	return percent, ''
end

--- How the args from the parameters are handeld
---@type function[]
local operators = {}
-- ! args start with the operator followed by the other args

--- repeat char x many times
---@param args string[]
---@return string | nil, string
operators['='] = function(args)
	local times = tonumber(args[2])
	local char = args[3]

	if times == nil or char == nil then
		return nil, match_msg(
			{ times == nil, err_msgs['NO_NUM_INCLUDED'] },
			{ char == nil, err_msgs['NO_CHAR_INCLUDED'] }
		)
	end

	return char:rep(times), ''
end

--- repeat char x many percent of the length
---@param args string[]
---@param opt Operators_opt
---@return string | nil, string
operators['/='] = function(args, opt)
	local char = args[3]
	local success, err = get_percent(args)

	if success == nil then
		return nil, err
	end

	local times = success * opt.pro_opt.length



	return char:rep(math.floor(times + 0.5)), ''
end

--- repeates the chars x many procent out of length minus label length
---@param args string[]
---@param opt Operators_opt
---@return string | nil, string
operators['!'] = function( args, opt )
	local char = args[3]
	local percent, err = get_percent(args)

	if not percent then
		return nil, err
	end

	local times = percent * (opt.pro_opt.length - utf8.len(opt.pro_opt.label))

	return char:rep(math.floor(times + 0.5)), ''
end

--- repeates the chars x many procent out of length minus constant characters 
---@param args string[]
---@param opt Operators_opt
---@return string | nil, string
operators['/!'] = function( args, opt )
	local char = args[3]
	local percent, err = get_percent(args)

	if not percent then
		return nil, err
	end

	local times = (percent * opt.pro_opt.length) - (opt.const_chars * percent)

	return char:rep(math.floor(times + 0.5)), ''
end

--- repeates the chars x many procent out of leanth minus label length minus constant chars
---@param args string[]
---@param opt Operators_opt
---@return string | nil, string
operators['?'] = function( args, opt )
	local char = args[3]
	local percent, err = get_percent(args)

	if not percent then
		return nil, err
	end

	local times = (percent * (opt.pro_opt.length - utf8.len(opt.pro_opt.label))) - (opt.const_chars * percent)

	return char:rep(math.floor(times + 0.5)), ''
end

--- returnt either x amount of chars or a "label"
---@param args string[]
---@param opt Operators_opt
---@return string | nil, string
operators['c'] = function( args, opt )
	local const_name = args[2]
	local char = args[3]

	local const = opt.pro_opt.consts[const_name]

	if const == nil then
		return nil, err_msgs['UNVALID_CONST']
	end

	if type(const) == 'number' then
		if char == nil then 
			return nil, err_msgs['NO_CHAR_INCLUDED']
		end

		return char:rep(const), ''
	elseif type(const) == 'string' then
		return const, ''
	end

	return nil, err_msgs['UNVALID_CONST_TYPE']
end

return operators
