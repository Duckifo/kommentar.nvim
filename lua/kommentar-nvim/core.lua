-- module / M
local core = {}

---@type User_Config
local Config = require('kommentar-nvim.config').config

-- import utils
local split = vim.fn.split
local find_closing_char = require('kommentar-nvim.lib.utils').find_closing_char
local report = require('kommentar-nvim.lib.error').report
local err_msg = require('kommentar-nvim.lib.error').err_msgs

local string_len = vim.fn.strchars
local operator_functions = require('kommentar-nvim.operators')

---@class Proccess_Opt
---@field label string
---@field length integer
---@field consts table

--- Proccess format by the options passed
--- @param format string Format to use
--- @param opt Proccess_Opt
core.Proccess_pattern = function(format, opt)
	-- Start by `Tokenizing` format
	-- (Spliting it up before being parsed)

	-- Format gets split up into a table separated by `%(param)`
	-- tokenized_format: {'<==','%(param)','==>'}


	-- Start by spliting format into lines separated by `,`
	local format_lines = split(format, ',')

	-- For parsing later
	-- Amount of characters that are not added with this proccess
	local constant_characters = {}

	-- `tokens` the output of Tokenizing format:
	--[[ example
		{
			{'<==','%(param),'==>'},
			.. next tokenized format line
		}	
	]]
	---@type string[][]
	local tokens = {}

	for format_idx, format_line in pairs(format_lines) do
		constant_characters[format_idx] = 0

		-- the local buffer for every `format line`
		local line_tokens = {}
		line_tokens[1] = ''

		-- if next_start_idx >= char_idx skip
		-- Used to skip param chars
		local next_start_idx = -math.huge
		local idx = 1

		for char_idx = 1, string_len(format_line) do
			-- skip param characters
			if next_start_idx >= char_idx then
				goto continue
			end

			local char = format_line:sub(char_idx, char_idx)

			if char ~= '%' then
				-- count amount of constant_characters
				constant_characters[format_idx] = constant_characters[format_idx] + 1
				-- add char to buffer
				line_tokens[idx] = line_tokens[idx] .. char
				goto continue
			end

			idx = idx + 1

			---@type Error_info
			local error_info = {
				index = char_idx,
				line_nr = format_idx,
				line = format_line
			}

			-- TODO: check if next char is start paren & throw error if not

			local start_paren_idx = char_idx + 1
			local end_paren_idx = find_closing_char(start_paren_idx, ')', format_line)

			if not end_paren_idx then
				report(error_info, err_msg['NO_CLOSING_PAREN'])
			end

			-- To skip the param characters so they dont get added to buffer as constant_characters
			next_start_idx = end_paren_idx

			-- add param to buffer
			local param = format_line:sub(char_idx, end_paren_idx)
			line_tokens[idx] = param

			-- create new buffer for next if its constant char
			if format_line:sub(end_paren_idx + 1, end_paren_idx + 1) ~= '%' then
				idx = idx + 1
				line_tokens[idx] = ''
			end

			::continue::
		end
		tokens[format_idx] = line_tokens
	end

	-- Get the commentstring or
	local comment_string = vim.bo.commentstring:gsub(' %%s', '')

	-- Parsing format && Evaluating
	-- Turn the tokenized_buffer into the finnished string now!
	local buffer = comment_string
	for i, tokenized_line in pairs(tokens) do
		--[[ token format example:
			{'====','%(param)','abcd'}
		]]
		for j, token in pairs(tokenized_line) do
			-- skip if token cant be parsed

			if token:sub(1, 1) ~= '%' then
				buffer = buffer .. token
				goto continue
			end

			---@type Error_info
			local error_info = {
				index = string_len(buffer) + 2,
				line_nr = i,
				line = format_lines[i]
			}

			-- < Evaluate / Transform >

			-- Get the values passed in param, and split by ':' into a table
			local parameter = split(token:match('%((.-)%)'), ':')
			local operator = parameter[1]

			-- Check if operator is existant
			if operator_functions[operator] == nil then
				report(error_info, err_msg['NON_VALID_OPERATOR'])
				return
			end

			---@type Operators_opt
			local operator_opt = {
				const_chars = constant_characters[i],
				pro_opt = opt
			}

			-- Call operators function
			local result, err = operator_functions[operator]( parameter, operator_opt )

			if result == nil then
				report(error_info, err or 'unknown error')
				return
			end

			-- Write output to buffer
			buffer = buffer .. result

			::continue::
		end
		-- Add comment on end if option is true
		if Config.comment_on_both_sides then
			buffer = buffer .. comment_string
		end
		-- Add new line and comment_string
		buffer = buffer .. '\n' .. (i == #tokens and '' or comment_string)
	end

	return buffer
end

---@param label string
---@param length integer
---@param format string
core.create_divider_write_buf = function(label, length, format)
	-- make sure arguments are set well and done
	label = label or ''
	length = length or Config.default_length
	format = format or Config.format

	-- Can be used in format by doing %(c:`name`)
	-- Types can be string or int
	local constants = {
		['len'] = length,
		['label'] = label,
		['/label'] = string_len(label)
	}

	---@type Proccess_Opt
	local opt = {
		label = label,
		length = length,
		consts = constants
	}

	-- Proccess and get the `comment_buffer`
	local comment_buffer = core.Proccess_pattern(format, opt)

	-- return if failed
	if comment_buffer == nil then return end

	-- Get neovim buffer and current `colum` and `row`
	local Current_nvim_buffer = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	-- write the `comment_buffer` to neovims buffer at current `row`
	vim.api.nvim_buf_set_lines(Current_nvim_buffer, row, row, false, split(comment_buffer, '\n'))
end

return core
