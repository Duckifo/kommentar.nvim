--[[		Hayo there :P - Duckifo - 8/2/2025
		Lookat the `:help` page if your lost
]]

---@meta
---@version LuaJIT-2.1


-- The default config
---@type User_Config
local default_config = {
	format = {},
	comment_on_both_sides = true,
	default_length = 50,

	reindent = true,
	respect_autoindent = true,

	parsing = {
		modifiers = {},
		operators = {}
	},

	comment_strings = {
		c = '/*%s*/',
		cpp = '/*%s*/',
		lua = '--%s--',
	},
}

local kommentar_nvim = {}
---@param _Config User_Config -- Configuration
kommentar_nvim.setup = function(_Config)
	---@type Config
	local Config = {}
	Config.user_config = default_config
	Config.plugin_root = string.sub(debug.getinfo(1).source, 2, string.len('/lua/kommentar-nvim/init.lua') * -1 - 1)

	for key, value in pairs(_Config) do
		if not default_config[key] then
			print("[kommentar.nvim]: non valid key `", key, "` found in passed config!")
			goto continue
		end

		Config.user_config[key] = value
		::continue::
	end

	-- add formats to the `formats` module
	local format_M = require('kommentar-nvim.formats')
	for format_id, format in pairs(Config.user_config.format) do
		format_M.formats[format_id] = format
	end

	-- reload keys so user formats are visible in autocompleate
	format_M.reload_keys()

	-- init the `config`
	require('kommentar-nvim.config').config = Config

	-- source `commands`
	require('kommentar-nvim.commands')
end

return kommentar_nvim
