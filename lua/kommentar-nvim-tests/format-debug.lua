--- debug formats used to debug the parser , `new feat etc ...`
local debug_format = {}
debug_format.debug_formats = {
	dbug_line = '%(/!:100:=)',
	-- ... 
}

--- Load the debug_formats into `format module`
debug_format.load_debug_formats = function()
	local formats_m = require('kommentar-nvim.formats')

	-- add the formats to formats module
	for key, format in pairs(debug_format.debug_formats) do
		formats_m.formats[key] = format
	end

	-- reload keys to add them to the autocompleate
	formats_m.reload_keys()
end

return debug_format
