local split = vim.fn.split
local get_commentstring = require('kommentar-nvim.lib.utils').get_commentstring

local utf8 = require('utf8')

--- Used for modifing buffer after uts proccessed, for mods like overflow that need total len
local mods = {}

--- used to add / remove characters if it needs to be shorter / longer
mods['overflow'] = function(line_buf, idx, len)
	-- find current line 
	local line_idx = math.floor(idx / len) + 1
	local char = utf8.sub(line_buf, idx, idx)

	-- get the diff between wanted len and current len
	local line_len = utf8.len(line_buf)
	local len_diff = len - line_len

	-- nothing to do so return buf as is
	if len_diff == 0 then return line_buf end

	-- edit buffer to either shrink or expand area
	if len_diff < 0 then
		-- remove chars
		return utf8.sub(line_buf,1,idx) .. utf8.sub(line_buf, idx + math.abs(len_diff) + 1)
	else
		-- add chars
		return utf8.sub(line_buf,1,idx) .. char:rep(len_diff) .. utf8.sub(line_buf,idx+1)
	end
end

return mods
