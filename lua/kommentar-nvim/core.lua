-- module / M
local core = {}

---@type Config
local Config = require('kommentar-nvim.config').config

-- import utils
local split = vim.fn.split
local find_closing_char = require('kommentar-nvim.lib.utils').find_closing_char
local get_commentstring = require('kommentar-nvim.lib.utils').get_commentstring

local report = require('kommentar-nvim.lib.error').report
local err_msg = require('kommentar-nvim.lib.error').err_msgs

local utf8 = require('utf8')

local modifier_functions = require('kommentar-nvim.parsing.modifiers')
local operator_functions = require('kommentar-nvim.parsing.operators')

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

	-- Start by spliting format into lines separated by `,`
	local format_lines = split(format, ',')

	-- For parsing later
	-- Amount of characters that are not added with this proccess
	-- Indexed by line { [1]=5 } -> line 1 has 5 constant chars
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

		for char_idx = 1, utf8.len(format_line) do
			-- skip param characters
			if next_start_idx >= char_idx then
				goto continue
			end

			local char = utf8.sub(format_line, char_idx, char_idx)

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
			local param = utf8.sub(format_line, char_idx, end_paren_idx)
			line_tokens[idx] = param

			-- create new buffer for next if its constant char
			if utf8.sub(format_line, end_paren_idx + 1, end_paren_idx + 1) ~= '%' then
				idx = idx + 1
				line_tokens[idx] = ''
			end

			::continue::
		end
		tokens[format_idx] = line_tokens
	end

	-- Get the commentstring
	local comment_string = get_commentstring()


	-- Parsing format && Evaluating
	-- Turn the tokenized_buffer into the finnished string now!
	local buffer = ''
	for i, tokenized_line in pairs(tokens) do
		--[[ token format example:
			{'====','%(param)','abcd'}
		]]

		-- [buf_idx] = mod
		-- used to edit string after generated, eg `overflow`
		-- edits string from module, `modifiers.lua`
		local modifiers = {}

		-- the buffer the current line
		local line_buffer = ''
		for j, token in pairs(tokenized_line) do
			-- skip if token cant be parsed

			if utf8.sub(token, 1, 1) ~= '%' then
				line_buffer = line_buffer .. token
				goto continue
			end

			---@type Error_info
			local error_info = {
				index = utf8.len(line_buffer .. buffer) + 2,
				line_nr = i,
				line = format_lines[i]
			}

			-- < Evaluate / Transform >

			-- Get the values passed in param, and split by ':' into a table
			local parameter = split(token:match('%((.-)%)'), '|')
			local operator_parameter = split(parameter[1], ':')
			local operator = operator_parameter[1]

			-- get modifiers, split by `|`
			local modifier_parameters = parameter
			modifier_parameters[1] = nil

			-- add modifier to moduifier table, so it can be used later
			for _, modifier in pairs(modifier_parameters) do
				modifiers[utf8.len(line_buffer)] = modifier
			end

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
			local result, err = operator_functions[operator](operator_parameter, operator_opt)

			if result == nil then
				report(error_info, err or 'unknown error')
				return
			end

			-- Write output to line_buffer
			line_buffer = line_buffer .. result

			::continue::
		end

		-- apply modifiers
		for idx, mod in pairs(modifiers) do
			local mod_func = modifier_functions[mod]
			if mod_func == nil then
				return
			end

			local success, modified_buf = pcall(mod_func, line_buffer, idx + 1, opt.length)
			if not success then
				vim.api.nvim_err_writeln('Failed to transform with modifier: \n' .. modified_buf)
				return
			end

			line_buffer = modified_buf
		end

		-- write line buffer into buffer with commentstring
		-- Does commentstring use %s or not? eg: c='/*%s*/'
		if not comment_string:find('%%s') then
			buffer = buffer ..
				comment_string ..
				line_buffer .. (Config.user_config.comment_on_both_sides and comment_string or '') .. '\n'
		else
			buffer = buffer .. string.format(comment_string .. '\n', line_buffer)
		end
	end


	return buffer
end

---@param label string
---@param length integer
---@param format string
---@param buf integer
---@param start integer
---@param end_ integer
core.creatediv_write_buf = function(label, length, format, buf, start, end_)
	-- make sure arguments are set well and done
	label = label or ''
	length = length or Config.user_config.default_length
	format = format or 'Somthing went wrong :( ... your problem now >:)'

	-- Can be used in format by doing %(c:`name`)
	-- Types can be string or int
	local constants = {
		['len'] = length,
		['label'] = label,
		['/label'] = utf8.len(label)
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

	-- write the `comment_buffer` to neovims buffer at current `row`
	vim.api.nvim_buf_set_lines(buf, start, end_, false, split(comment_buffer, '\n'))

	-- reindent written lines

	if Config.user_config.respect_autoindent and not vim.bo.autoindent then return end
	if Config.user_config.reindent then
		local comment_lines = utf8.gmatch(comment_buffer, '\n')
		local idx = 1
		for _ in comment_lines do
			vim.api.nvim_win_set_cursor(0, {start + idx, 0})
			vim.cmd('normal! ==')
			idx = idx + 1
		end
	end
end

---@param label string
---@param length integer
---@param format string
core.creatediv_write_curbuf = function(label, length, format)
	-- Get neovim buffer and current `colum` and `row`
	local Current_nvim_buffer = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	core.creatediv_write_buf(label, length, format, Current_nvim_buffer, row, row)
end

core.preview_format = function(label, lenght, format)

end

return core
