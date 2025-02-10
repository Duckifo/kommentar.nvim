---@type Config
local Config = {}
local debug_mode = false

-- import utils
local split = require('scd-nvim.utils').split
local includes = require('scd-nvim.utils').includes
local report = require('scd-nvim.error').report
local err_msg = require('scd-nvim.error').err_msgs

-- characters that will be removed in format, and not dissplayed
---@type string[]
local non_legal_characters = {
	'%', ','
}

--- Used to get index to closest closing parentheses
---@param line string
---@param i integer
---@return integer | boolean?
local function get_endIndex_of_parameter(line, i)
	-- find the `end index`, till closest closing parentheses
	local end_index = i
	while true do
		local char = line:sub(end_index, end_index)
		if char == ')' then
			break
		elseif end_index - i > 25 then -- add killswitch
			-- return an error
			return nil
		end
		end_index = end_index + 1
	end
	return end_index
end

--- Used to get amount of non constant characters in string
---@param line string
---@return integer | nil
local function get_amount_nonConstant_chars(line)
	local non_consts = 0
	for i = 0, #line do
		local char = line:sub(i, i)
		if char == '%' then
			local end_index = get_endIndex_of_parameter(line, i)
			if end_index == nil then
				return nil
			end
			local amount = end_index - i
			non_consts = non_consts + amount
		end
	end

	return non_consts
end

--[[ Used to get the values from `prefixes` ]]
---@param line string
---@param length integer len of line
---@param index integer index of current char
---@param label string
---@param const_amount integer
---@return string, integer
local function parse_prefix(line, length, index, label, const_amount)
	--[[ eg.
		%(o:`char`) -> overflow - filled in with char
		%(c:`@name`) -> constants
			`len` -> length
			`label` -> adds label to buffer
			`/label` -> length of label
		%(=:`x`:`char`)		-> rep char `x` many times
		%(̣/=:`x`:`char`)		-> rep char `x` many percent of `len`
		%(!:`x`:`char`)		-> rep char `x` many percent of `len` minus `label len`
		%(/!:`x`:`char`)		-> rep char `x` many percent of `len` minus constant chars
		%(?:`x`:`char`)		-> rep char `x` many percent of `len` minus `label len` minus constant chars
	]]

	-- init empty `buffer`
	local buffer = ""

	-- get end index
	local end_index = get_endIndex_of_parameter(line, index)

	if end_index == nil then
		error(err_msg['NO_CLOSING_BRACKET'])
	end

	-- parameter -> the string inbetween `(*)`
	local parameter = split(line:sub(index + 2, end_index - 1), ':')
	local operator = parameter[1]:gsub(' ', '')
	local arg2 = parameter[2] -- often refered to as value
	local arg3 = parameter[3] -- often refered to as char
	local percentage = (tonumber(arg2) or 0) / 100

	if operator == nil then
		error(err_msg['NO_OPERATOR'])
	end

	if arg2 == nil then
		error(err_msg['NOT_ENOUGH_ARG'] .. '\n ' .. (includes({ '/=', '=', '/!', '!', '?' }, operator) == true
			and err_msg.HELP_NOT_ENOUGH_ARG['=/=!/!?']
			or (operator == 'c' and err_msg.HELP_NOT_ENOUGH_ARG['c'] or err_msg.HELP_NOT_ENOUGH_ARG['o'])))
	end

	-- amount of times to repeat
	local x = 0

	if operator == '?' or '!' or '/!' then
		x = operator == '/!'
			and length * percentage  -- `/!` uses
			or (length - #label) * percentage -- `?` & `!` uses

		-- for every constans char remove `percentage` * `1`
		if operator == '?' or operator == '/!' then
			x = x - const_amount * percentage
		end
	end

	if operator == '/=' then
		x = length * percentage
	end

	if operator == '=' then
		x = tonumber(arg2)
	end

	-- not really consts :)
	local const = {
		['len'] = length,
		['label'] = label,
		['/label'] = #label
	}

	if operator == 'c' then
		if not const[arg2] then error('Non valid const, format') end

		local const_value = const[arg2]
		if type(const_value) == 'number' then
			x = const_value
		elseif type(const_value) == 'string' then
			buffer = buffer .. const_value
			goto continue
		end
	end

	if arg3 == nil then
		error(err_msg['NO_CHAR_INCLUDED'])
	end

	buffer = buffer .. arg3:rep(math.ceil(x))
	::continue::

	-- return buffer and end_index
	return buffer, end_index
end

-- Used to get the `comment buffer` from the `format`
---@param format string
---@param length integer
---@param label string
---@return string | nil
local function parse(format, length, label)
	local buffer = ""

	-- split the format into `X` many lines
	---@type string[]
	local lines = split(format, ',')

	-- index for wich iteration trough characters can be skipped
	local timeout_i = -math.huge

	for line_index, line in pairs(lines) do
		local const_amount = #line - (get_amount_nonConstant_chars(line) or 0)
		for char_index = 0, #line do
			if char_index <= timeout_i and not debug_mode == true then
				goto skip
			end

			local char = line:sub(char_index, char_index)

			-- check if prefix then get the string of that prefix
			if char == '%' then
				local success, prefix_buffer, end_index = xpcall(function()
					return parse_prefix(line, length, char_index, label, const_amount)
				end, function(err)
					report({ index = char_index, line = line, line_nr = line_index }, err)
					return nil
				end)

				if success then
					buffer = buffer .. prefix_buffer
				else
					return nil
				end

				-- Skip the characters that was just parced
				timeout_i = end_index
				goto continue
			end

			-- check if character is legal
			if includes(non_legal_characters, char) then goto continue end

			-- add character to buffer
			buffer = buffer .. char

			::continue::

			-- always check & add comment string if needed
			if char_index == #line then
				-- Is end of line, if `comment_on_both_sides` flag then add commentstring
				if Config.comment_on_both_sides then
					buffer = buffer .. vim.bo.commentstring:gsub(' %%s', '')
				end

				-- add newline `\n` to the end of buffer
				buffer = buffer .. '\n'
			elseif char_index == 0 then
				-- Is start of line, add commentstring to buffer
				buffer = buffer .. vim.bo.commentstring:gsub(' %%s', '')
			end

			::skip::
		end
		timeout_i = -math.huge
	end

	-- return the buffer
	return buffer
end

---@param label string -> the label of the divider `%t`
---@param length integer -> the length of the divider `%l`
---@param format string -> optional format
local create_divider = function(label, length, format)
	-- Parse and get the `comment_buffer` (AKA: proccess the format to get the comment)
	local comment_buffer = parse(format or Config.format, length, label)

	-- return if failed
	if comment_buffer == nil then return end

	-- Get neovim buffer and current `colum` and `row`
	local Current_nvim_buffer = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	-- write the `comment_buffer` to neovims buffer at current `row` and `colum`
	vim.api.nvim_buf_set_lines(Current_nvim_buffer, row, row, false, split(comment_buffer, '\n'))
end

-- The init function to set the cofig, and create the `ScdCreateDivider` command
---@param _Config Config Set the config
local set_config = function(_Config)
	Config = _Config

	-- Create new user command, for creating new divider at current cursor.pos and buffer
	vim.api.nvim_create_user_command("ScdCreateDivider", function(args_string)
		--[[ Args:	for overiding setup options
			 [1] -> len:			int
			 [2] -> ask for label: 	bool
			 [3] -> format: 		string
			 [4] -> debug:			bool
		]]

		-- make args into an table split by `;`
		local args = split(args_string.args, ';')

		---@type integer
		local length = tonumber(args[1]) or Config.default_length or 100
		local format = args[3]:lower() == 'x' and Config.format or args[3]

		debug_mode = args[4] == 'true' or false

		-- init empty label
		local label = ''

		-- check if `ask for label` flag is true
		if args[2] == "true" then
			-- ask for label
			vim.ui.input({ prompt = Config.label_prompt }, function(input)
				label = input
			end)
		end

		-- Create divider
		create_divider(label, length, format)
	end, { nargs = '*' })
end

return set_config
