---@type Config
local Config = {}
local initialized = false

-- import utils
local split = require('scd-nvim.utils').split
local includes = require('scd-nvim.utils').includes

-- characters that will be removed in format, and not dissplayed
---@type string[]
local non_legal_characters = {
	'%', ',',
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', '?', 'l', 't'
}

--[[ Used to get the values from `prefixes`
	eg.
	`%t` would return the label -> `this is the label`
	`m%10` would repeat `m` 10% of `len` -> `mmmmm` -- doesnt work, to lazy to fix aswell
]]
---@param line string
---@param length integer len of line
---@param index integer index of current char
---@param label string
---@return string
function parse_prefix(line, length, index, label)
	-- Used to get the `int` value after `%`
	local function get_number(i)
		local number = ""
		local iterations = 0
		while true do
			local char = line:sub(i + iterations, i + iterations)
			if tonumber(char) then
				number = number .. char
			else
				return tonumber(number)
			end
			iterations = iterations + 1
		end
	end

	-- values like `l` are held here
	local values = {
		l = length
	}

	-- init empty `buffer`
	local buffer = ""

	-- get last and previos characters
	local prev_char = line:sub(index - 1, index - 1)
	local next_char = line:sub(index + 1, index + 1)

	-- init empty `avalable_space` used for how many times prec char will be repeated
	local avalable_space = 0

	-- Check for what action to preform & preform it
	if next_char == '?' or next_char == '!' then -- use total space not used by other characters
		assert(get_number(index + 2) ~= nil, "Non valid numeral after %?")
		local percentage =(get_number(index + 2) / 100)
		avalable_space = (length - #label) * percentage 

		if next_char == '?' then
			-- remove space for every constant character
			for i = 0, #line do
				local char = line:sub(i, i)
				if not includes(non_legal_characters, char) then
					avalable_space = avalable_space - 1 * percentage
				end
			end
		end
	else
		if next_char == 'l' then
			avalable_space = length
		elseif next_char == 't' then
			-- add label to buffer
			buffer = label
			goto continue
		else
			avalable_space = length * (get_number(index + 1) / 100)
		end
	end

	-- write to `buffer`
	buffer = string.rep(prev_char, math.floor(avalable_space))
	::continue::
	return buffer
end

-- Used to get the `comment buffer` from the `format`
---@param format string
---@param length integer
---@param label string
---@return string
function parse(format, length, label)
	local buffer = ""

	-- if (#label) + 1 % 2 ~= 0 then
	-- 	label = label .. " "
	-- end

	-- split the format into `X` many lines
	---@type string[]
	local lines = split(format, Config.format_prefixes.divider_character)
	print(#lines)

	for line_index, line in pairs(lines) do
		for char_index = 0, #line do
			local char = line:sub(char_index, char_index)

			-- check if prefix then get the string of that prefix
			if char == Config.format_prefixes.prefix_character then
				buffer = buffer .. parse_prefix(line, length, char_index, label)
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
		end
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
	initialized = true

	-- Create new user command, for creating new divider at current cursor.pos and buffer
	vim.api.nvim_create_user_command("ScdCreateDivider", function(args_string)
		--[[ Args:	for overiding setup options
			 [1] -> len:			int
			 [2] -> ask for label: 	bool
			 [3] -> format: 		string
		]]

		-- make args into an table split by `;`
		local args = split(args_string.args, ';')

		---@type integer
		local length = tonumber(args[1]) or Config.default_length or 100
		local format = args[3]:lower() == 'x' and Config.format or args[3]

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
