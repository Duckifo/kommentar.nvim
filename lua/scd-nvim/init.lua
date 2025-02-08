-- Hayo :P

---@class Format_config
---@field prefix_character string The prefix character defaulted to `%`
---@field divider_character string The divider characyer defaulted to `,`

---@class Config
---@field format string The default format for dividers -- see more information about at :help smc.nvim-configuration
---@field format_prefixes Format_config The prefixes for the `format` allow changes in `prefix_char` & `divider_char` (WARNING: will break the default formats)
---@field comment_on_both_sides boolean Use comment string on both sides ( // <== hello ==> // ) or ( // <== hello ==> )
---@field default_length integer The default len

-- The default config
---@type Config
local default_config = {
	format = "<=%l>,< %!50%t %!50>,<=%l>",
	format_prefixes = {
		prefix_character = "%",
		divider_character = ","
	},
	comment_on_both_sides = true,
	default_length = 50
}

local smc_nvim = {}
---@param _Config Config -- Configuration
smc_nvim.setup = function(_Config)
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

	require 'smc.nvim.comment'(final_config)
end

smc_nvim.setup({})

return smc_nvim
