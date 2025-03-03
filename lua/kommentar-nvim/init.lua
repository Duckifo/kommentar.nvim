--[[		Hayo there :P - Duckifo - 8/2/2025
		Lookat the `:help` page if your lost
]]

---@meta
---@version LuaJIT-2.1

---@class User_Config
---@field format? string[] A table of custom formats you can add, indexed by a key_name / `format_id`
---@field comment_on_both_sides? boolean Use comment string on both sides ( // <== hello ==> // ) or ( // <== hello ==> )
---@field default_length? integer The default len

---@class Config
---@field format string[] See above in user_config
---@field comment_on_both_sides boolean See above in user_config
---@field default_length integer See above in user_config
---@field plugin_root string Path to plugin root directory

-- The default config
---@type User_Config
local default_config = {
	format = {},
	comment_on_both_sides = true,
	default_length = 50,
}

local kommentar_nvim = {}
---@param _Config User_Config -- Configuration
kommentar_nvim.setup = function(_Config)
	---@type Config
	local Config = default_config
	Config.plugin_root = string.sub(debug.getinfo(1).source, 2, string.len('/lua/kommentar-nvim/init.lua') * -1 -1)

	for key, value in pairs(_Config) do
		if not default_config[key] then 
			print("[kommentar.nvim]: non valid key `", key, "` found in passed config!")
			goto continue
		end

		Config[key] = value
    	::continue::
	end

	-- add formats to the `formats` module
	local format_M = require('kommentar-nvim.formats')
	for format_id, format in pairs(Config.format) do
		format_M.formats[format_id] = format
	end

	-- reload keys so user formats are visible in autocompleate
	format_M.reload_keys()

	-- init the `config`
	require('kommentar-nvim.config').config = Config
	require('kommentar-nvim.config').init = true

	-- source `commands`
	require('kommentar-nvim.commands')
end

return kommentar_nvim
