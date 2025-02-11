--[[		Hayo there :P - Duckifo - 8/2/2025
		Lookat the `:help` page if your lost
]]

---@class Format_config
---@field prefix_character string The prefix character defaulted to `%`
---@field divider_character string The divider characyer defaulted to `,`

---@class Config
---@field format? string The default format for dividers -- see more information about at :help smc.nvim-configuration
---@field comment_on_both_sides? boolean Use comment string on both sides ( // <== hello ==> // ) or ( // <== hello ==> )
---@field default_length? integer The default len
---@field label_prompt? string The prompt that asks for label default `Enter label > `

-- The default config
---@type Config
local default_config = {
	format = " <=:-%(?:50.05:~) ) %(c:label) ( %(?:50:~)-:=> ",
	comment_on_both_sides = true,
	default_length = 50,
	label_prompt = "Enter label > "
}

local scd_nvim = {}
---@param _Config Config -- Configuration
scd_nvim.setup = function(_Config)
	---@type Config
	local final_config = default_config
	for key, value in pairs(default_config) do
		if value == nil then goto continue end
		if not final_config[key] then 
			print("[smc.nvim]: non valid key `", key, "` found in passed config!")
			goto continue
		end

		final_config[key] = value
    	::continue::
	end

	-- init `core` and `commands`
	require('scd-nvim.core').setup(final_config)
	require('scd-nvim.commands')
end

return scd_nvim
