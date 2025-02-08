---@type Config
local Config = {}

---@param str string
---@param sep string char
---@return string[]
function split(str, sep)
	local result = {}
	for match in str:gmatch("([^" .. sep .. "]+)") do
		table.insert(result, match)
	end
	return result
end

local function includes(tbl, value)
	for _, v in ipairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

---@type string[]
local non_legal = {
	'%', ',',
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', '?', 'l', 't'
}


---@param line string
---@param length integer len of line
---@param index integer index of current char
---@param label string
---@return string
function parse_prefix(line, length, index, label)
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


	local result = ""

	local prev_char = line:sub(index - 1, index - 1)
	local next_char = line:sub(index + 1, index + 1)

	if next_char == '?' then -- use total space not used by other characters
		local avalable_space = length * (get_number(index + 2) / 100)
		for i = 0, #line do
			local char = line:sub(i, i)
			if not includes(non_legal, char) then
				avalable_space = avalable_space - 1
			end
		end

		result = string.rep(prev_char, math.floor(avalable_space))
	elseif next_char == '!' then                                           -- use avalable space
		local avalable_space = (length - #label) * (get_number(index + 2) / 100) --TODO make it better
		result = string.rep(prev_char, math.floor(avalable_space))
	else
		if next_char == 'l' then
			result = string.rep(prev_char, length)
		elseif next_char == 't' then
			result = label
		else
			local avalable_space = length * (get_number(index + 2) / 100)
			result = string.rep(prev_char, math.floor(avalable_space))
		end
	end

	return result
end

---@param format string
---@param length integer
---@param label string
---@return string
function parse(format, length, label)
	local result = ""

	-- make label viable
	if (#label) + 1 % 2 ~= 0 then
		label = label .. " "
	end

	---@type string[]
	local lines = split(format, Config.format_prefixes.divider_character)

	for line_index, line in pairs(lines) do
		for char_index = 0, #line do
			local char = line:sub(char_index, char_index)

			-- check for what action to preform
			if char == Config.format_prefixes.prefix_character then
				-- find out what to preform
				result = result .. parse_prefix(line, length, char_index, label)
				goto continue
			end

			if includes(non_legal, char) then goto continue end

			result = result .. char

			if char_index == #line then
				if Config.comment_on_both_sides then
					result = result .. vim.bo.commentstring
				end
				result = result .. '\n'
			elseif char_index == 0 then
				result = result .. vim.bo.commentstring
			end

			::continue::
		end
	end

	return result
end

---@param label string
---@param length integer
---@param _Config Config optinal config
---@param row integer
---@param col integer
local create_divider = function(label, length, _Config, row, col)
	local divider = parse(_Config.format or Config.format, length, label)
	local bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(bufnr, row - 1, col, false, split(divider, '\n'))
end

---@param _Config Config Set the config
local set_config = function(_Config)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	Config = _Config
	vim.api.nvim_create_user_command("ScdCreateDivider", function(args)
		local label = args[1]
		if not args[1] then
			vim.ui.input({ prompt = "Enter label > " }, function(input)
				label = input
			end)
		end

		create_divider(label, args[2] or Config.default_length, args[3] or {}, row, col)
	end, { nargs = '+' })
end

return set_config
