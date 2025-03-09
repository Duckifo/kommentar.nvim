
--                                           Config types                                           --
---@class User_Config.parsing
--- Add custom operators like the `?` or `/!` operator
--- See TODO for how functions are formated.
---@field operators function[]
--- Add custom modifiers like the `overflow` modifier
--- See TODO for when and how to create a mod.
---@field modifiers function[]

--- the type that can be passed at setup
---@class User_Config
---@field format? string[] A table of custom formats you can add, indexed by a key_name / `format_id`
---@field comment_on_both_sides? boolean Use comment string on both sides ( // <== hello ==> // ) or ( // <== hello ==> )
---@field default_length? integer The default len
---@field reindent? boolean Should the comment be reindented when written to buf?
---@field respect_autoindent? boolean Should reindent be on when autoindent is off?
---@field parsing? User_Config.parsing Parsing options and more
---@field comment_strings? string[] Overides a language commentstring eg `lua='--'` use %s to get div between comment eg `c='/*%s*/'`

--- the type that `global config` stores
---@class Config
---@field user_config User_Config 
---@field plugin_root string Path to plugin root directory

--                                           Global config                                          --
--- global config
---@type { config: Config }
local M = { config = nil }
return M
